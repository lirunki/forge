#!/usr/bin/env node
'use strict';

// Static/contract tests for the Agent Task Lab sample (samples/Forge_Agent_Task_Lab.html).
// Pins the public API surface the demo relies on (runTask, workspace, cancel,
// files.pick, tool presets, task_run_script scenario) so the sample cannot
// silently drift from the host contract. Run with: node tests/forge-agent-task-lab.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');

const sample = fs.readFileSync('samples/Forge_Agent_Task_Lab.html', 'utf8');
const html = fs.readFileSync('www/index.html', 'utf8');
const api = fs.readFileSync('docs/api.md', 'utf8');
const tools = fs.readFileSync('docs/tools.md', 'utf8');
let passed = 0;
function test(name, fn) { fn(); passed++; console.log('✓ ' + name); }

test('sample is a self-contained HTML file with inline script', () => {
  assert.match(sample, /<!doctype html>/i);
  assert.match(sample, /<title>Agent Task Lab<\/title>/);
  const scripts = [...sample.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script\s*>/gi)].map(m => m[1]);
  assert.ok(scripts.length === 1, 'demo must inline exactly one script block');
  assert.doesNotThrow(() => new Function(scripts[0]), 'inline script must be syntactically valid');
  // No external script/src or CDN dependency.
  assert.ok(!/<script[^>]*\ssrc=/i.test(sample), 'demo must not load external scripts');
});

test('demo delegates to ForgeHost.ai.runTask — not a hand-rolled agent loop', () => {
  assert.match(sample, /ForgeHost\.ai\.runTask/);
  assert.ok(!/callChatSync|runModelOnce|buildPayload|APP_TOOLS/.test(sample), 'demo must not own a chat/tool loop');
});

test('demo threads task, instructions, profile, skills, workspace, tools, and riskMax', () => {
  for (const needle of [
    'task:', 'profile:', 'skills:', 'tools:', 'riskMax:', 'maxRounds:',
    'attachments:', 'workspace:', 'request.instructions = instructions',
  ]) {
    assert.ok(sample.includes(needle), 'request must include ' + needle);
  }
  // Build a tools selection object with preset + optional names/groups.
  assert.match(sample, /buildTools/);
  assert.match(sample, /tools = \{ preset: preset \}/);
  assert.match(sample, /tools\.names = names/);
  assert.match(sample, /tools\.groups = groups/);
});

test('demo advertises the runTask cancellation path', () => {
  assert.match(sample, /ai\.cancel/);
  assert.match(sample, /Stop/);
  // active-run tracking so stale callbacks cannot mutate the UI.
  assert.match(sample, /activeId/);
});

test('demo surfaces workspace CRUD + artifacts via ai.workspace APIs', () => {
  for (const m of ['workspace.list', 'workspace.read', 'workspace.clear']) {
    assert.ok(sample.includes(m), 'demo must use ' + m);
  }
  assert.match(sample, /renderFiles/);
  assert.match(sample, /artifacts/);
});

test('demo handles streaming tokens and tool/round events', () => {
  assert.match(sample, /onToken/);
  assert.match(sample, /onRound/);
  assert.match(sample, /onToolCall/);
  assert.match(sample, /onToolResult/);
});

test('demo includes a task_run_script orchestration scenario', () => {
  assert.match(sample, /data-scenario="script"/);
  assert.match(sample, /task_run_script/);
  assert.match(sample, /forge\.tools\.run/);
  assert.match(sample, /forge\.finish/);
});

test('demo includes the other reference scenarios', () => {
  for (const id of ['workspace', 'research', 'report', 'attachment', 'smoke']) {
    assert.match(sample, new RegExp('data-scenario="' + id + '"'), 'missing scenario ' + id);
  }
});

test('docs reference task_run_script alongside the task workspace tools', () => {
  assert.match(tools, /task_run_script/);
  assert.match(tools, /forge\.tools\.run/);
  assert.match(tools, /forge\.finish/);
  assert.match(tools, /cannot call `task_run_script`/);
  assert.match(api, /task_run_script/);
  assert.match(api, /forge\.tools\.run/);
});

test('host implements task_run_script and the nested-call safety gates', () => {
  assert.match(html, /name: 'task_run_script'/);
  assert.match(html, /async function runTaskScript/);
  assert.match(html, /task_run_script cannot be nested/);
  assert.match(html, /if \(policy && !policy\.allowedToolNames\.has\(name\)\) return \{ ok: false, error: 'Tool ' \+ name \+ ' was not enabled for this agent run' \}/);
  assert.match(html, /await agentConfirmTool\(name, a, entry\.risk \|\| 'safe', \{ agentPolicy: policy \}\)/);
  assert.match(html, /runOptions\[AGENT_RUN_POLICY\] = policy/);
});

test('sample is registered in the samples manifest', () => {
  const manifest = JSON.parse(fs.readFileSync('samples/manifest.json', 'utf8'));
  const entry = manifest.samples.find((s) => s.file === 'Forge_Agent_Task_Lab.html');
  assert.ok(entry, 'manifest must include Forge_Agent_Task_Lab.html');
  assert.equal(entry.id, 'forge-agent-task-lab');
  assert.equal(entry.category, 'AI');
  assert.equal(entry.minimumForgeVersion, '2.7.107');
  assert.equal(entry.icon, '🧪');
});

console.log('\n' + passed + ' tests passed.');
