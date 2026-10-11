#!/usr/bin/env node
'use strict';

// Contract tests for the task_run_script sandboxed orchestrator tool added in
// Phase 7. The tool lets a task agent run a JS script that batches task
// workspace tools and authorized host tools deterministically (no LLM inside).
// Full Worker execution is browser-only; these tests pin the schema, the
// host-enforced safety wiring, and the agent-loop dispatch contract.
// Run with: node tests/ai-task-run-script.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

const html = fs.readFileSync('www/index.html', 'utf8');
let passed = 0;
function test(name, fn) { fn(); passed++; console.log('✓ ' + name); }

// Extract the task workspace tool schemas (same region as ai-task-workspace.test.js).
const schemaStart = html.indexOf(' const TASK_WORKSPACE_LIMITS = Object.freeze(');
const schemaEnd = html.indexOf(' // ——— Agent risk sheet', schemaStart);
assert.notEqual(schemaStart, -1, 'task workspace manager not found');
assert.notEqual(schemaEnd, -1, 'task workspace manager end not found');
const sandbox = {};
vm.runInNewContext(
  html.slice(schemaStart, schemaEnd) +
    '\nthis.api = { TASK_WORKSPACE_TOOL_SCHEMAS, TASK_WORKSPACE_TOOL_NAMES };',
  sandbox,
  { filename: 'www/index.html' },
);
const { TASK_WORKSPACE_TOOL_SCHEMAS, TASK_WORKSPACE_TOOL_NAMES } = sandbox.api;

test('task_run_script schema is present with code required and description optional', () => {
  const tool = TASK_WORKSPACE_TOOL_SCHEMAS.find(t => t.function.name === 'task_run_script');
  assert.ok(tool, 'task_run_script schema must exist');
  const p = tool.function.parameters;
  assert.equal(p.type, 'object');
  assert.deepEqual(JSON.parse(JSON.stringify(p.required)), ['code']);
  assert.ok(p.properties.code, 'code property must exist');
  assert.equal(p.properties.code.type, 'string');
  assert.ok(p.properties.description, 'description property must exist');
  assert.ok(!p.required.includes('description'), 'description must be optional');
});

test('task_run_script is a reserved task workspace tool name', () => {
  assert.ok(TASK_WORKSPACE_TOOL_NAMES.has('task_run_script'), 'TASK_WORKSPACE_TOOL_NAMES must include task_run_script');
});

test('schema description documents the script sandbox, primary file API, secondary tools, and no-nesting', () => {
  const tool = TASK_WORKSPACE_TOOL_SCHEMAS.find(t => t.function.name === 'task_run_script');
  const d = tool.function.description;
  for (const needle of [
    'sandboxed Worker', 'api.readText', 'api.write', 'api.list', 'api.print',
    'forge.tools.run', 'forge.tools.list', 'forge.sleep', 'forge.print',
    'forge.finish', 'cannot call task_run_script', 'host-enforced risk',
    'no DOM', 'complex computation',
  ]) {
    assert.ok(d.includes(needle), 'description must mention: ' + needle);
  }
});

test('runTaskScript helper is defined and reuses the builder Worker runtime', () => {
  assert.match(html, /async function runTaskScript\(args, ctx\)/);
  assert.match(html, /runCodeModeProgram\(code,/);
  assert.match(html, /getCodeModeLimits\(\)/);
  assert.match(html, /BUILDER_JS_MAX_CODE_BYTES/);
});

test('runTaskScript blocks nesting of task_run_script', () => {
  assert.match(html, /if \(name === 'task_run_script'\) return \{ ok: false, error: 'task_run_script cannot be nested/);
});

test('runTaskScript routes task workspace tools through runTaskWorkspaceTool', () => {
  assert.match(html, /if \(TASK_WORKSPACE_TOOL_NAMES\.has\(name\) && name !== 'task_run_script'\)[\s\S]{0,120}return runTaskWorkspaceTool\(appId, workspaceId, name, a\)/);
});

test('runTaskScript provides a direct workspace file API (api.readText/write/list/print)', () => {
  assert.match(html, /const fileApi = async \(method, a\) =>/);
  assert.match(html, /method === 'readText'\)/);
  assert.match(html, /method === 'write'\)/);
  assert.match(html, /method === 'list'\)/);
  assert.match(html, /method === 'print'\)/);
  assert.match(html, /runTaskWorkspaceTool\(appId, workspaceId, 'task_workspace_read'/);
  assert.match(html, /runTaskWorkspaceTool\(appId, workspaceId, 'task_workspace_write'/);
  assert.match(html, /runTaskWorkspaceTool\(appId, workspaceId, 'task_workspace_list'/);
  assert.match(html, /fileApi,/);
});

test('worker source defines a conditional api object gated on the init flag', () => {
  assert.match(html, /const api = d\.api \? \{/);
  assert.match(html, /readText: function \(p\) \{ return __rpc\("api", \{ method: "readText"/);
  assert.match(html, /write: function \(p, data, mime, b64\) \{ return __rpc\("api", \{ method: "write"/);
  assert.match(html, /\} : null;/);
  // the script function receives both forge and api
  assert.match(html, /new Function\("forge", "api", "return \(async \(\) => \{"/);
  assert.match(html, /fn\(forge, api\)\)/);
});

test('runCodeModeProgram wires the api RPC and the init flag only when fileApi is set', () => {
  assert.match(html, /const fileApi = typeof o\.fileApi === 'function' \? o\.fileApi : null/);
  assert.match(html, /if \(type === 'api'\) \{/);
  assert.match(html, /if \(!fileApi\) return \{ ok: false, error: 'file api not available in this run' \}/);
  assert.match(html, /worker\.postMessage\(\{ rpc: 'init', code, api: !!fileApi \}, \[mc\.port2\]\)/);
});

test('runTaskScript enforces host-tool policy + confirmation before toolsRun', () => {
  // host tools: policy membership, risk tier approval, agentConfirmTool, then toolsRun
  assert.match(html, /if \(policy && !policy\.allowedToolNames\.has\(name\)\) return \{ ok: false, error: 'Tool ' \+ name \+ ' was not enabled for this agent run' \}/);
  assert.match(html, /if \(policy && !policy\.allowedRiskSet\.has\(String\(entry\.risk \|\| 'safe'\)\)\) return \{ ok: false, error: 'Tool ' \+ name \+ ' risk tier was not approved for this agent run' \}/);
  assert.match(html, /const allowed = await agentConfirmTool\(name, a, entry\.risk \|\| 'safe', \{ agentPolicy: policy \}\)/);
  assert.match(html, /runOptions\[AGENT_RUN_POLICY\] = policy/);
  assert.match(html, /return await toolsRun\(runOptions\)/);
});

test('runTaskScript returns forge.finish result and caps oversized output', () => {
  assert.match(html, /return \{ ok: true, result: r\.result, description: desc \}/);
  assert.match(html, /task_run_script result too large/);
  assert.match(html, /return a smaller value or write files to the workspace instead/);
});

test('runTaskScript threads the agent abort signal', () => {
  assert.match(html, /signal: ctx\.signal \|\| null/);
});

test('agent loop dispatches task_run_script to runTaskScript with policy + signal', () => {
  const dispatch = html.indexOf("if (tname === 'task_run_script') {");
  assert.notEqual(dispatch, -1, 'agent loop must branch on task_run_script');
  const region = html.slice(dispatch, dispatch + 400);
  assert.match(region, /await runTaskScript\(targs,/, 'must call runTaskScript');
  assert.match(region, /appId: taskWorkspaceAppId/, 'must pass appId');
  assert.match(region, /workspaceId: taskWorkspaceId/, 'must pass workspaceId');
  assert.match(region, /signal: agentAbortController \? agentAbortController\.signal : null/, 'must pass abort signal');
  assert.match(region, /agentPolicy: agentToolPolicy/, 'must pass the agent tool policy');
  assert.match(region, /riskMax,/, 'must pass riskMax');
});

test('agent loop emits nested toolCall + scriptPrint events for script-driven calls', () => {
  const dispatch = html.indexOf("if (tname === 'task_run_script') {");
  const region = html.slice(dispatch, dispatch + 600);
  assert.match(region, /agentEmit\('toolCall', \{ round, name: String\(n\), nested: true \}\)/);
  assert.match(region, /agentEmit\('scriptPrint'/);
});

test('task_run_script is only offered when a task workspace is requested', () => {
  // The schemas are appended only inside the `params.__forgeTaskWorkspace != null` block.
  const wsBlock = html.indexOf("if (params.__forgeTaskWorkspace != null)");
  assert.notEqual(wsBlock, -1, 'task workspace block must exist');
  const concat = html.indexOf('tools = tools.concat(TASK_WORKSPACE_TOOL_SCHEMAS)', wsBlock);
  assert.notEqual(concat, -1, 'task workspace schemas must be appended inside the workspace block');
});

test('task_run_script is not registered as a host tool (collision guard stays intact)', () => {
  // The host-collision guard rejects any HOST_TOOL_REGISTRY entry whose name
  // collides with a reserved task workspace tool name. task_run_script must
  // remain a workspace-only tool, never a host registry entry.
  const hostRegStart = html.indexOf('const HOST_TOOL_REGISTRY = [');
  const hostRegEnd = html.indexOf('];', hostRegStart);
  const hostSlice = html.slice(hostRegStart, hostRegEnd);
  assert.ok(!/name:\s*'task_run_script'/.test(hostSlice), 'task_run_script must not appear in HOST_TOOL_REGISTRY');
});

console.log('\n' + passed + ' tests passed.');
