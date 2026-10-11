#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

const html = fs.readFileSync('www/index.html', 'utf8');
let passed = 0;
function test(name, fn) { fn(); passed++; console.log('✓ ' + name); }

const mockRegistry = [
  { name: 'web_search', group: 'web', risk: 'safe', description: 'Search' },
  { name: 'web_fetch', group: 'web', risk: 'safe', description: 'Fetch' },
  { name: 'get_location', group: 'location', risk: 'sensitive', permissions: ['location'], description: 'Location' },
  { name: 'sms_send', group: 'sms', risk: 'danger', permissions: ['sms'], description: 'Send SMS' },
  { name: 'clipboard_read', group: 'device', risk: 'sensitive', description: 'Clipboard' },
  { name: 'launch_app', group: 'apps', risk: 'confirm', description: 'Launch' },
  { name: 'bridge_call', group: 'meta', risk: 'confirm', description: 'Bridge' },
];
const mockAppTools = [{ name: 'app_helper', group: 'app', risk: 'confirm', description: 'App handler' }];
const prelude = `
const HOST_TOOL_REGISTRY = ${JSON.stringify(mockRegistry)};
const HOST_BRIDGE_ALLOW = new Set(['getAppInfo']);
const appTools = ${JSON.stringify(mockAppTools)};
function toolRiskRank(r) { return ({safe:0,sensitive:1,confirm:2,danger:3}[String(r || 'safe')] ?? 0); }
function listAppTools() { return appTools; }
function toolsToOpenAI(e) { return {type:'function',function:{name:e.name,parameters:e.parameters||{type:'object',properties:{}}}}; }
`;

const selectionStart = html.indexOf('    // These are availability gates, not a second tool catalog.');
const selectionEnd = html.indexOf('    // Task-scoped, host-managed virtual workspaces', selectionStart);
assert.ok(selectionStart >= 0 && selectionEnd > selectionStart, 'tool policy helpers not found');
const selectionSandbox = { navigator: { clipboard: { readText() {}, writeText() {} } } };
vm.runInNewContext(prelude + html.slice(selectionStart, selectionEnd) + '\nthis.api = { toolsFilterEntries, toolsList, agentToolAvailableForCapabilities, normalizeAgentToolSelection };', selectionSandbox);
const { toolsFilterEntries, toolsList, agentToolAvailableForCapabilities, normalizeAgentToolSelection } = selectionSandbox.api;

const resultStart = html.indexOf('    function agentBoundToolResult(');
const resultEnd = html.indexOf('    async function agentConfirmTool(', resultStart);
assert.ok(resultStart >= 0 && resultEnd > resultStart, 'tool result safety helpers not found');
const resultSandbox = { HOST_TOOL_REGISTRY: mockRegistry, listAppTools: () => mockAppTools };
vm.runInNewContext(html.slice(resultStart, resultEnd) + '\nthis.api = { agentBoundToolResult, agentPublicToolArgs, agentPublicToolResult, agentPublicToolCalls };', resultSandbox);
const { agentBoundToolResult, agentPublicToolArgs, agentPublicToolResult, agentPublicToolCalls } = resultSandbox.api;

const bridgeStart = html.indexOf('    const HOST_BRIDGE_METHOD_TOOL = Object.freeze(');
const bridgeEnd = html.indexOf('    async function toolsBridgeCall(', bridgeStart);
assert.ok(bridgeStart >= 0 && bridgeEnd > bridgeStart, 'bridge method risk table not found');
const bridgeSandbox = {};
vm.runInNewContext(html.slice(bridgeStart, bridgeEnd) + '\nthis.methodRisk = hostBridgeMethodRisk; this.HOST_BRIDGE_METHOD_TOOL = HOST_BRIDGE_METHOD_TOOL;', bridgeSandbox);

function plain(value) { return JSON.parse(JSON.stringify(value)); }

test('task-agent tools default to the safe preset and safe risk tier', () => {
  assert.deepEqual(plain(normalizeAgentToolSelection(undefined, undefined)), {
    preset: 'safe', names: null, groups: null, riskMax: 'safe',
  });
  assert.equal(toolsList({}).riskMax, 'safe');
  assert.deepEqual(plain(toolsFilterEntries({}).map(x => x.name)), ['web_search', 'web_fetch']);
});

test('supports canonical presets and selected names/groups without accepting custom schemas', () => {
  assert.deepEqual(plain(normalizeAgentToolSelection('web-research', 'danger')), {
    preset: 'web-research', names: null, groups: ['web'], riskMax: 'safe',
  });
  assert.deepEqual(plain(normalizeAgentToolSelection({ preset: 'selected', names: ['web_search'], groups: ['web'], riskMax: 'confirm' }, undefined)), {
    preset: 'selected', names: ['web_search'], groups: ['web'], riskMax: 'confirm',
  });
  assert.deepEqual(plain(normalizeAgentToolSelection([{ type: 'function', function: { name: 'web_fetch' } }], 'confirm')), {
    preset: 'selected', names: ['web_fetch'], groups: null, riskMax: 'confirm',
  });
  assert.throws(() => normalizeAgentToolSelection({ preset: 'selected' }, 'safe'), /requires names or groups/);
  assert.throws(() => normalizeAgentToolSelection({ preset: 'all', override: true }, 'safe'), /unsupported tools option/);
  assert.throws(() => normalizeAgentToolSelection({ preset: 'selected', names: ['bad/name'] }, 'safe'), /valid names/);
  assert.throws(() => normalizeAgentToolSelection({ preset: 'safe', groups: ['sms'] }, 'safe'), /preset:"selected"/);
  assert.throws(() => normalizeAgentToolSelection({ preset: 'all', riskMax: 'unlimited' }, undefined), /riskMax must be/);
});

test('selection filters canonical schemas by risk, names, groups, and capabilities', () => {
  const safe = toolsFilterEntries({ riskMax: 'safe' });
  assert.deepEqual(plain(safe.map(x => x.name)), ['web_search', 'web_fetch']);
  assert.deepEqual(plain(toolsFilterEntries({ riskMax: 'danger', names: ['sms_send'], groups: ['sms'] }).map(x => x.name)), ['sms_send']);
  assert.deepEqual(plain(toolsFilterEntries({ riskMax: 'danger', names: ['sms_send'], groups: ['web'] })), []);
  assert.deepEqual(plain(toolsFilterEntries({ riskMax: 'danger', groups: ['location'], capabilities: { location: false } })), []);
  assert.equal(agentToolAvailableForCapabilities(mockRegistry.find(x => x.name === 'get_location'), { location: true }), true);
  assert.equal(agentToolAvailableForCapabilities(mockRegistry.find(x => x.name === 'get_location'), { location: false }), false);
  assert.equal(toolsFilterEntries({ riskMax: 'confirm', names: ['app_helper'], appId: 'app' })[0].name, 'app_helper');
});

test('tool access requests are host-granted per run and cancellation closes the pending grant UI', () => {
  const agentStart = html.indexOf("case 'ai.agent': {");
  const agentEnd = html.indexOf("case 'ai.chatStream': {", agentStart);
  const agent = html.slice(agentStart, agentEnd);
  assert.match(agent, /await agentRequestToolAccess\(candidateToolEntries, agentCallId, agentCancelFlag\)/);
  assert.match(agent, /let tools = allowedToolEntries\.map\(toolsToOpenAI\)/, 'only canonical registry schemas reach the model');
  assert.doesNotMatch(agent, /normalizeToolsParam\(params\.tools/);
  assert.match(agent, /allowedToolNames\.has\(tname\) && allowedRiskSet\.has/);
  assert.match(agent, /runOptions\[AGENT_RUN_POLICY\] = agentToolPolicy/);
  assert.match(agent, /allowedNames: allowedToolNames/);
  assert.match(html, /risk === 'sensitive' && opts\.agentPolicy && opts\.agentPolicy\.allowedNames && opts\.agentPolicy\.allowedNames\.has\(name\)/);
  assert.match(html, /agentToolAccessPending\.set\(callId/);
  assert.ok(html.includes('if (cancelToolAccess) { try { cancelToolAccess(); } catch (_) {} aborted = true; }'));
  assert.match(html, /data-tier="sensitive"/);
  assert.match(html, /data-tier="danger"/);
  assert.match(html, /if \(allowed && params\.__hasOnToolCall\)/, 'mini-app hook remains a post-host-authorization veto');
  assert.match(html, /agentAskMiniAppToolCall\(agentCallId, toolCallId, \{ round, name: tname, args: agentPublicToolArgs\(tname, targs, risk\) \}\)/, 'mini-app veto callback receives redacted sensitive arguments');
});

test('bridge_call enforces the risk of the nested host method', () => {
  assert.equal(bridgeSandbox.methodRisk('sms.read'), 'sensitive');
  assert.equal(bridgeSandbox.methodRisk('clipboard.read'), 'sensitive');
  assert.equal(bridgeSandbox.methodRisk('sms.send'), 'danger');
  assert.equal(bridgeSandbox.methodRisk('phone.call'), 'danger');
  assert.equal(bridgeSandbox.methodRisk('apps.list'), 'safe');
  assert.equal(bridgeSandbox.methodRisk('unclassified.method'), 'confirm');
  assert.equal(bridgeSandbox.HOST_BRIDGE_METHOD_TOOL['sms.read'], 'sms_list');
  assert.equal(bridgeSandbox.HOST_BRIDGE_METHOD_TOOL['sms.send'], 'sms_send');
  assert.equal(bridgeSandbox.HOST_BRIDGE_METHOD_TOOL['clipboard.read'], 'clipboard_read');
  assert.equal(bridgeSandbox.HOST_BRIDGE_METHOD_TOOL['radio.set'], 'radio_set');
  assert.match(html, /if \(policy && risk !== 'safe'\)/);
  assert.match(html, /Non-safe bridge method ' \+ id \+ ' cannot run through bridge_call in an agent/);
  assert.match(html, /Bridge method ' \+ id \+ ' blocked by riskMax=/);
  assert.match(html, /Bridge method ' \+ id \+ ' requires a tier not approved for this agent run/);
});

test('tool outputs are bounded and sensitive arguments/results are redacted from app event history', () => {
  const bounded = agentBoundToolResult({ text: 'x'.repeat(5000) }, 1200);
  assert.equal(bounded.truncated, true);
  assert.ok(JSON.stringify(bounded).length < 1300);
  const secretArgs = { address: '+15551234567', query: 'private' };
  const publicArgs = agentPublicToolArgs('sms_list', secretArgs, 'sensitive');
  assert.equal(publicArgs.redacted, true);
  assert.equal(JSON.stringify(publicArgs).includes('+15551234567'), false);
  const publicResult = agentPublicToolResult('sms_list', { messages: [{ body: 'secret text' }] }, 'sensitive');
  assert.equal(publicResult.redacted, true);
  assert.equal(JSON.stringify(publicResult).includes('secret text'), false);
  const calls = agentPublicToolCalls([{ id: 'c1', function: { name: 'sms_send', arguments: JSON.stringify(secretArgs) } }]);
  assert.equal(JSON.stringify(calls).includes('+15551234567'), false);
  assert.match(html, /const modelOut = agentModelToolResult\(tname, out, 56000\)/);
  assert.match(html, /const publicOut = agentPublicToolResult\(tname, out, risk\)/);
});

console.log(`\n${passed} agent tool-policy tests passed.`);
