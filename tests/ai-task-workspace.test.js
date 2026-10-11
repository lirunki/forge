#!/usr/bin/env node
'use strict';

// No-dependency tests for Forge's isolated virtual task-workspace manager.
// Run with: node tests/ai-task-workspace.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

const html = fs.readFileSync('www/index.html', 'utf8');
const start = html.indexOf('    const TASK_WORKSPACE_LIMITS = Object.freeze(');
const end = html.indexOf('    // ——— Agent risk sheet', start);
assert.notEqual(start, -1, 'task workspace manager not found');
assert.notEqual(end, -1, 'task workspace manager end not found');
const sandbox = {};
vm.runInNewContext(
  html.slice(start, end) + '\nthis.api = { TASK_WORKSPACE_LIMITS, normalizeTaskWorkspaceId, normalizeTaskWorkspacePath, createTaskWorkspaceManager, TASK_WORKSPACE_TOOL_SCHEMAS, taskWorkspaceManager, runTaskWorkspaceTool };',
  sandbox,
  { filename: 'www/index.html' },
);
const { TASK_WORKSPACE_LIMITS, normalizeTaskWorkspaceId, normalizeTaskWorkspacePath, createTaskWorkspaceManager, TASK_WORKSPACE_TOOL_SCHEMAS, taskWorkspaceManager, runTaskWorkspaceTool } = sandbox.api;
let passed = 0;
function test(name, fn) { fn(); passed++; console.log('✓ ' + name); }

test('uses centralized Phase 4 quotas and validates workspace IDs', () => {
  assert.deepEqual(JSON.parse(JSON.stringify(TASK_WORKSPACE_LIMITS)), {
    maxWorkspaces: 32, maxFiles: 200, maxFileBytes: 10 * 1024 * 1024, maxTotalBytes: 64 * 1024 * 1024,
    maxSessionBytes: 128 * 1024 * 1024, maxReadChars: 50000,
  });
  assert.equal(normalizeTaskWorkspaceId('compare.v1_2-3'), 'compare.v1_2-3');
  for (const invalid of ['', '../outside', 'a/b', 'a b', '.hidden', 'x'.repeat(81)]) {
    assert.throws(() => normalizeTaskWorkspaceId(invalid), /workspace id/);
  }
});

test('normalizes relative paths and rejects traversal, absolute paths, and controls', () => {
  assert.equal(normalizeTaskWorkspacePath('docs\\./reports//final.md'), 'docs/reports/final.md');
  assert.throws(() => normalizeTaskWorkspacePath('/etc/passwd'), /relative/);
  assert.throws(() => normalizeTaskWorkspacePath('C:\\temp\\secret'), /relative/);
  assert.throws(() => normalizeTaskWorkspacePath('../escape'), /traversal/);
  assert.throws(() => normalizeTaskWorkspacePath('a/../../escape'), /traversal/);
  assert.throws(() => normalizeTaskWorkspacePath('a\u0000b'), /NUL|invalid segment/);
  assert.throws(() => normalizeTaskWorkspacePath(''), /empty/);
  assert.throws(() => normalizeTaskWorkspacePath(new Array(34).fill('a').join('/')), /segments/);
});

test('reuses matching app/workspace namespaces but isolates other apps and IDs', () => {
  const manager = createTaskWorkspaceManager();
  manager.write('app-a', 'shared', 'notes.txt', 'belongs to app a');
  manager.write('app-a', 'shared', 'next.txt', 'same workspace');
  assert.equal(manager.read('app-a', 'shared', 'notes.txt').content, 'belongs to app a');
  assert.equal(manager.list('app-b', 'shared').count, 0);
  assert.equal(manager.list('app-a', 'other').count, 0);
});

test('supports list/read/write/edit/delete and explicit clear with bounded reads', () => {
  const manager = createTaskWorkspaceManager({ maxReadChars: 50 });
  assert.equal(manager.write('app', 'qa', 'report.txt', 'alpha beta alpha', 'text/markdown').ok, true);
  const first = manager.read('app', 'qa', 'report.txt', { limit: 5 });
  assert.equal(first.content, 'alpha');
  assert.equal(first.truncated, true);
  assert.equal(manager.read('app', 'qa', 'report.txt', { offset: 6, limit: 5 }).content, 'beta ');
  const list = manager.list('app', 'qa');
  assert.equal(list.count, 1);
  assert.equal(list.files[0].path, 'report.txt');
  assert.equal(manager.edit('app', 'qa', 'report.txt', 'alpha', 'A', true).replacements, 2);
  assert.equal(manager.read('app', 'qa', 'report.txt', { limit: 50 }).content, 'A beta A');
  assert.equal(manager.deleteFile('app', 'qa', 'report.txt').deleted, 'report.txt');
  manager.write('app', 'qa', 'a.txt', '123');
  manager.write('app', 'qa', 'b.txt', '4567');
  const cleared = manager.clear('app', 'qa');
  assert.equal(cleared.filesDeleted, 2);
  assert.equal(cleared.bytesFreed, 7);
  assert.equal(manager.list('app', 'qa').count, 0);
  assert.equal(manager.list('app', 'qa').totalBytes, 0);
});

test('enforces count, per-file, and total byte quotas atomically', () => {
  const manager = createTaskWorkspaceManager({ maxFiles: 2, maxFileBytes: 8, maxTotalBytes: 12, maxReadChars: 5 });
  assert.equal(manager.write('app', 'limited', 'one', '12345678').ok, true);
  assert.equal(manager.write('app', 'limited', 'two', '1234').ok, true);
  assert.match(manager.write('app', 'limited', 'three', '1').error, /file-count limit/);
  assert.match(manager.write('app', 'limited', 'one', '123456789').error, /file limit/);
  assert.match(manager.write('app', 'limited', 'two', '12345').error, /total-size limit/);
  assert.equal(manager.read('app', 'limited', 'one').content, '12345');
  assert.equal(manager.list('app', 'limited').count, 2);
  assert.equal(manager.write('app', 'utf8', 'word', 'é').bytes, 2);
});

test('limits total virtual workspaces and bytes per host session', () => {
  const byCount = createTaskWorkspaceManager({ maxWorkspaces: 1 });
  assert.equal(byCount.write('app-a', 'one', 'f', 'x').ok, true);
  assert.match(byCount.write('app-a', 'two', 'f', 'y').error, /session workspace-count limit/);
  assert.equal(byCount.clear('app-a', 'one').ok, true);
  assert.equal(byCount.write('app-a', 'two', 'f', 'y').ok, true);

  const byBytes = createTaskWorkspaceManager({ maxWorkspaces: 2, maxSessionBytes: 10, maxTotalBytes: 10 });
  assert.equal(byBytes.write('app-a', 'one', 'a', '12345678').ok, true);
  assert.match(byBytes.write('app-b', 'two', 'b', '123').error, /session workspace total-size limit/);
});

test('tool dispatch performs scoped CRUD and returns safe path errors', () => {
  const appId = 'workspace-dispatch-test';
  const workspaceId = 'runner-' + Date.now().toString(36);
  assert.equal(runTaskWorkspaceTool(appId, workspaceId, 'task_workspace_list', {}).ok, true);
  assert.equal(runTaskWorkspaceTool(appId, workspaceId, 'task_workspace_write', { path: 'reports/a.md', content: 'draft text' }).ok, true);
  assert.equal(runTaskWorkspaceTool(appId, workspaceId, 'task_workspace_read', { path: 'reports/a.md' }).content, 'draft text');
  assert.equal(runTaskWorkspaceTool(appId, workspaceId, 'task_workspace_edit', { path: 'reports/a.md', find: 'draft', replace: 'verified' }).ok, true);
  assert.equal(runTaskWorkspaceTool(appId, workspaceId, 'task_workspace_read', { path: 'reports/a.md' }).content, 'verified text');
  assert.match(runTaskWorkspaceTool(appId, workspaceId, 'task_workspace_write', { path: '../escape', content: 'x' }).error, /traversal/);
  assert.match(runTaskWorkspaceTool(appId, workspaceId, 'task_workspace_read', { path: '/etc/passwd' }).error, /relative/);
  assert.equal(runTaskWorkspaceTool(appId, workspaceId, 'task_workspace_delete', { path: 'reports/a.md' }).ok, true);
  assert.equal(runTaskWorkspaceTool(appId, workspaceId, 'task_workspace_read', { path: 'reports/a.md' }).ok, false);
  assert.equal(taskWorkspaceManager.clear(appId, workspaceId).filesDeleted, 0);
  assert.equal(runTaskWorkspaceTool(appId, workspaceId, 'unknown', {}).ok, false);
});

test('advertises only scoped task workspace tools and wires them into host result/APIs', () => {
  const managerSource = html.slice(start, end);
  assert.doesNotMatch(managerSource, /activeBuilderFs|builderNormPath|activeBuilderOwner/,
    'task workspace manager must stay separate from the Forge-it builder workspace');
  const agentStart = html.indexOf("case 'ai.agent': {");
  const agentEnd = html.indexOf("case 'ai.chatStream': {", agentStart);
  const agentSource = html.slice(agentStart, agentEnd);
  assert.match(agentSource, /agentCancelFlags\.set\(agentCallId, agentCancelFlag\)/);
  assert.match(agentSource, /if \(agentCancelFlag\.cancelled\)/);
  assert.match(agentSource, /runTaskWorkspaceTool\(taskWorkspaceAppId, taskWorkspaceId, tname, targs\)/);
  assert.match(agentSource, /if \(taskWorkspaceAuto && taskWorkspaceId\) taskWorkspaceManager\.clear/,
    'auto-created workspace is released if setup or the agent call fails');
  assert.match(agentSource, /agentCancelFlags\.delete\(agentCallId\)/);
  const names = TASK_WORKSPACE_TOOL_SCHEMAS.map(tool => tool.function.name).sort();
  assert.deepEqual(JSON.parse(JSON.stringify(names)), [
    'task_run_script', 'task_workspace_delete', 'task_workspace_edit', 'task_workspace_list', 'task_workspace_read', 'task_workspace_write',
  ]);
  for (const name of names) assert.match(html, new RegExp(name));
  assert.match(html, /tools = tools\.concat\(TASK_WORKSPACE_TOOL_SCHEMAS\)/);
  assert.match(html, /runTaskWorkspaceTool\(taskWorkspaceAppId, taskWorkspaceId, tname, targs\)/);
  assert.match(html, /agentResult\.workspaceId = taskWorkspaceId/);
  assert.match(html, /agentResult\.artifacts = workspaceSnapshot\.ok \? workspaceSnapshot\.files : \[\]/);
  assert.match(html, /case 'ai\.workspace\.read'/);
  assert.match(html, /taskWorkspaceManager\.read\(currentApp\?\.id \|\| 'draft'/);
  assert.match(html, /workspace: \{[\s\S]*?list: \(opts\) => call\('ai\.workspace\.list'/);
  assert.match(html, /clear: \(opts\) => call\('ai\.workspace\.clear'/);
});

console.log(`\n${passed} task-workspace tests passed.`);
