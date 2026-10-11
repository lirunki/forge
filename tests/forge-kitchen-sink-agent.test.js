#!/usr/bin/env node
'use strict';

// Contract tests for the Agent exerciser section added to the Forge Kitchen
// Sink (www/index.html). Pins that the builtin kitchen-sink mini-app exposes a
// runnable exerciser for everything in the 1010 plan: runTask, attachments,
// workspace CRUD, task_run_script, tool/risk selection, and cancellation.
// Run with: node tests/forge-kitchen-sink-agent.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');

const html = fs.readFileSync('www/index.html', 'utf8');
const ksStart = html.indexOf('function kitchenSinkHtml() {');
const ksEnd = html.indexOf('function installKitchenSink() {', ksStart);
assert.notEqual(ksStart, -1, 'kitchenSinkHtml must exist');
const ks = html.slice(ksStart, ksEnd);
let passed = 0;
function test(name, fn) { fn(); passed++; console.log('✓ ' + name); }

test('kitchen sink has an Agent tab and section', () => {
  assert.match(ks, /\['agent','Agent'\]/);
  assert.match(ks, /<section id="tab-agent">/);
});

test('agent section advertises runTask, workspace, and task_run_script', () => {
  const sec = ks.slice(ks.indexOf('<section id="tab-agent">'));
  for (const needle of ['runTask', 'task workspace', 'task_run_script', 'sandboxed', '1010 plan']) {
    assert.ok(sec.includes(needle), 'agent section must mention: ' + needle);
  }
});

test('exerciser exposes profile, maxRounds, tool preset, risk ceiling, and skills', () => {
  for (const id of ['agProfile', 'agRounds', 'agPreset', 'agRisk', 'agSkills', 'agInstr', 'agTask']) {
    assert.ok(ks.includes('id="' + id + '"'), 'missing control ' + id);
  }
  // profiles include auto/tiny/normal/advanced/large
  for (const p of ['auto', 'tiny', 'normal', 'advanced', 'large']) {
    assert.ok(ks.includes('value="' + p + '"'), 'profile option ' + p + ' missing');
  }
});

test('exerciser wires Run, task_run_script, Stop, attach, and workspace CRUD handlers', () => {
  for (const id of ['agRun', 'agScript', 'agStop', 'agAttach', 'agList', 'agRead', 'agClear']) {
    assert.match(ks, new RegExp("getElementById\\('" + id + "'\\)\\.onclick"), 'handler ' + id + ' must be wired');
  }
});

test('Run handler calls ForgeHost.ai.runTask with workspace + attachments + events', () => {
  const run = ks.slice(ks.indexOf("getElementById('agRun').onclick"));
  const region = run.slice(0, 2400);
  assert.match(region, /H\(\)\.ai\.runTask\(/, 'must call ai.runTask');
  assert.match(region, /workspace:\s*\{\s*id:\s*agWorkspaceId\(\)\s*\}/, 'must pass a workspace id');
  assert.match(region, /attachments:\s*agPicked\s*\?\s*\[agPicked\]\s*:\s*\[\]/, 'must pass attachments');
  assert.match(region, /onToken:/, 'must stream tokens');
  assert.match(region, /onRound:/, 'must emit rounds');
  assert.match(region, /onToolCall:/, 'must expose tool calls (veto hook)');
  assert.match(region, /onToolResult:/, 'must expose tool results');
  assert.match(region, /riskMax:/, 'must thread riskMax');
  assert.match(region, /skills:/, 'must thread skills');
});

test('task_run_script exerciser runs a canned script scenario', () => {
  const sc = ks.slice(ks.indexOf("getElementById('agScript').onclick"));
  const region = sc.slice(0, 2400);
  assert.match(region, /H\(\)\.ai\.runTask\(/, 'must call ai.runTask');
  assert.match(region, /task_run_script/, 'task must mention task_run_script');
  assert.match(region, /api\.write/, 'task must describe the api.write file API');
  assert.match(region, /api\.readText/, 'task must describe the api.readText file API');
  assert.match(region, /forge\.finish/, 'task must describe forge.finish');
});

test('Stop handler cancels the active run via ForgeHost.ai.cancel', () => {
  const st = ks.slice(ks.indexOf("getElementById('agStop').onclick"));
  const region = st.slice(0, 400);
  assert.match(region, /H\(\)\.ai\.cancel\(agActiveId\)/, 'must call ai.cancel with the active id');
});

test('workspace CRUD buttons call the ai.workspace APIs', () => {
  assert.match(ks, /workspace\.list\(\{\s*workspaceId:\s*agWorkspaceId\(\)\s*\}\)/);
  assert.match(ks, /workspace\.read\(\{\s*workspaceId:\s*agWorkspaceId\(\)\s*,\s*path:\s*'report\.md'\s*\}\)/);
  assert.match(ks, /workspace\.clear\(\{\s*workspaceId:\s*agWorkspaceId\(\)\s*\}\)/);
});

test('attachment picker uses ForgeHost.files.pick', () => {
  const at = ks.slice(ks.indexOf("getElementById('agAttach').onclick"));
  const region = at.slice(0, 400);
  assert.match(region, /H\(\)\.files\.pick\(/, 'must call files.pick');
  assert.match(region, /image\/\*,application\/pdf/, 'must accept image/PDF');
});

test('the kitchen sink script still parses as valid JS', () => {
  const m = ks.match(/<script>([\s\S]*?)<\/script>/) || ks.match(/<script>([\s\S]*?)<\\\/script>/);
  assert.ok(m, 'script block must exist');
  assert.doesNotThrow(() => new Function(m[1]), 'kitchen sink script must be syntactically valid');
});

console.log('\n' + passed + ' tests passed.');
