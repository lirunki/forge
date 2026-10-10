#!/usr/bin/env node
'use strict';

// No-dependency contract tests for the injected ForgeHost.ai.runTask wrapper.
// Run with: node tests/ai-run-task.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

const html = fs.readFileSync('www/index.html', 'utf8');
const start = html.indexOf('  function buildTaskAgentRequest(input) {');
const end = html.indexOf('  window.ForgeHost = {', start);
assert.notEqual(start, -1, 'runTask request builder not found');
assert.notEqual(end, -1, 'runTask request builder boundary not found');
const sandbox = {};
vm.runInNewContext(
  html.slice(start, end) + '\nthis.__buildTaskAgentRequest = buildTaskAgentRequest;',
  sandbox,
  { filename: 'www/index.html' },
);
const buildRequest = sandbox.__buildTaskAgentRequest;
let passed = 0;
function test(name, fn) {
  fn();
  passed++;
  console.log('✓ ' + name);
}

const attachment = { type: 'image', mime: 'image/jpeg', dataUrl: 'data:image/jpeg;base64,AA==' };
const tool = { type: 'function', function: { name: 'web_search', parameters: { type: 'object' } } };
const onToken = () => {};
const onToolResult = () => {};

test('requires a non-empty task string', () => {
  assert.throws(() => buildRequest({}), /non-empty task string/);
  assert.throws(() => buildRequest({ task: '   ' }), /non-empty task string/);
  assert.throws(() => buildRequest({ task: { text: 'not a string' } }), /non-empty task string/);
});

test('composes instructions, JSON context, and task into one user turn', () => {
  const request = buildRequest({
    task: 'Compare A and B',
    instructions: 'Be concise and cite sources.',
    context: { items: ['A', 'B'] },
  });
  assert.equal(request.agentOptions.messages.length, 1);
  assert.equal(request.agentOptions.messages[0].role, 'user');
  const content = request.agentOptions.messages[0].content;
  assert.ok(content.indexOf('Mini-app instructions') < content.indexOf('Context data'));
  assert.ok(content.indexOf('Context data') < content.indexOf('Task:\nCompare A and B'));
  assert.ok(content.includes('{"items":["A","B"]}'));
  assert.equal(request.taskId, null);
});

test('forwards agent controls, callbacks, attachments, and a cancellation id', () => {
  const request = buildRequest({
    id: 'task-123', task: 'Inspect the image', instructions: 'Describe visible text.',
    context: 'single-file test context', attachments: [attachment], tools: [tool],
    riskMax: 'confirm', maxRounds: 4, providerId: 'gemini', model: 'gemini-2.5-flash',
    onToken, onToolResult,
  });
  const forwarded = request.agentOptions;
  assert.equal(request.taskId, 'task-123');
  assert.equal(forwarded.id, 'task-123');
  assert.equal(forwarded.attachments[0], attachment);
  assert.equal(forwarded.tools[0], tool);
  assert.equal(forwarded.riskMax, 'confirm');
  assert.equal(forwarded.maxRounds, 4);
  assert.equal(forwarded.providerId, 'gemini');
  assert.equal(forwarded.model, 'gemini-2.5-flash');
  assert.equal(forwarded.onToken, onToken);
  assert.equal(forwarded.onToolResult, onToolResult);
  assert.equal('task' in forwarded, false);
  assert.equal('instructions' in forwarded, false);
  assert.equal('context' in forwarded, false);
});

test('rejects deferred profile, skills, and workspace options instead of ignoring them', () => {
  for (const key of ['skills', 'profile', 'workspace']) {
    assert.throws(() => buildRequest({ task: 'Do work', [key]: key === 'skills' ? [] : {} }), new RegExp('option ' + key + ' is not available yet'));
  }
});

test('rejects context that cannot be serialized and prompts over 12000 characters', () => {
  const circular = {}; circular.self = circular;
  assert.throws(() => buildRequest({ task: 'Do work', context: circular }), /JSON-serializable/);
  assert.throws(() => buildRequest({ task: 'x'.repeat(12001) }), /max 12000 characters/);
});

test('runTask delegates to ai.agent exactly once and adds taskId to the result', () => {
  const methodStart = html.indexOf('runTask: async (opts) => {');
  const methodEnd = html.indexOf("cancel: (id) => call('ai.cancel'", methodStart);
  assert.notEqual(methodStart, -1, 'runTask bridge method not found');
  assert.notEqual(methodEnd, -1, 'runTask bridge method end not found');
  const method = html.slice(methodStart, methodEnd);
  assert.match(method, /buildTaskAgentRequest\(opts\)/);
  assert.match(method, /window\.ForgeHost\.ai\.agent\(request\.agentOptions\)/);
  assert.match(method, /taskId:\s*result\.id\s*\|\|\s*request\.taskId/);
  assert.doesNotMatch(method, /for\s*\(|while\s*\(/, 'runTask must not implement another agent loop');
});

console.log(`\n${passed} runTask contract tests passed.`);
