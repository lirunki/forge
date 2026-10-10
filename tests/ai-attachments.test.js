#!/usr/bin/env node
'use strict';

// No-dependency regression checks for the multimodal message builder used by
// ai.chat, ai.chatStream, and ai.agent. Run with: node tests/ai-attachments.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

const hostPath = 'www/index.html';
const html = fs.readFileSync(hostPath, 'utf8');
const start = html.indexOf('    const AI_MAX_IMAGES = 8;');
const end = html.indexOf('    function normalizeToolsParam(tools) {', start);
assert.notEqual(start, -1, 'could not locate shared multimodal helpers');
assert.notEqual(end, -1, 'could not locate end of shared multimodal helpers');

const sandbox = {
  atob,
  TextDecoder,
  Uint8Array,
};
vm.runInNewContext(
  html.slice(start, end) + `\nthis.__attachmentTestApi = {
    buildMiniAppAiMessages,
    openaiContentToGeminiParts,
  };`,
  sandbox,
  { filename: hostPath },
);
const { buildMiniAppAiMessages, openaiContentToGeminiParts } = sandbox.__attachmentTestApi;
const plain = value => JSON.parse(JSON.stringify(value));
const b64 = value => Buffer.from(value).toString('base64');
let passed = 0;
function test(name, fn) {
  fn();
  passed++;
  console.log('✓ ' + name);
}

const image = { type: 'image', name: 'photo.png', mime: 'image/png', dataUrl: 'data:image/png;base64,' + b64('image-bytes') };
const pdf = { type: 'file', name: 'report.pdf', mime: 'application/pdf', base64: b64('%PDF-1.7\nreport') };

test('attaches to the latest user turn without changing earlier turns', () => {
  const input = [
    { role: 'system', content: 'system' },
    { role: 'user', content: 'earlier question' },
    { role: 'assistant', content: 'earlier answer' },
    { role: 'user', content: 'What is in this photo?' },
  ];
  const built = buildMiniAppAiMessages({ messages: input, attachments: [image] }, { ensureSystem: false });
  assert.equal(built.messages.length, 4);
  assert.equal(built.messages[1].content, 'earlier question');
  assert.equal(built.messages[3].content[0].text, 'What is in this photo?');
  assert.equal(built.messages[3].content[1].type, 'image_url');
  assert.equal(built.stats.images, 1);
  assert.equal(built.stats.attachments, 1);
});

test('normalizes PDF as a rich file, not as an image', () => {
  const built = buildMiniAppAiMessages({
    messages: [{ role: 'user', content: 'Summarize this PDF' }],
    attachments: [pdf],
  }, { ensureSystem: false });
  const part = built.messages.at(-1).content[1];
  assert.equal(part.type, 'forge_file');
  assert.equal(part.mime, 'application/pdf');
  assert.equal(part.name, 'report.pdf');
  assert.equal(part.base64, pdf.base64);
  assert.equal(built.stats.images, 0);
  assert.equal(built.stats.files, 1);
});

test('preserves tool protocol rows while binding attachments to the user turn', () => {
  const assistantToolCall = {
    role: 'assistant', content: null,
    tool_calls: [{ id: 'c1', type: 'function', function: { name: 'web_search', arguments: '{}' } }],
  };
  const toolResult = { role: 'tool', tool_call_id: 'c1', name: 'web_search', content: '{"ok":true}' };
  const built = buildMiniAppAiMessages({
    messages: [{ role: 'user', content: 'Inspect this' }, assistantToolCall, toolResult],
    attachments: [image],
  }, { ensureSystem: false });
  assert.equal(built.messages.length, 3);
  assert.equal(built.messages[0].content[0].text, 'Inspect this');
  assert.equal(built.messages[0].content[1].type, 'image_url');
  assert.deepEqual(plain(built.messages[1].tool_calls), [assistantToolCall.tool_calls[0]]);
  assert.equal(built.messages[2].role, 'tool');
  assert.equal(built.messages[2].tool_call_id, 'c1');
});

test('maps normalized image and PDF parts to Gemini inline_data', () => {
  const built = buildMiniAppAiMessages({
    messages: [{ role: 'user', content: 'Check both' }],
    attachments: [image, pdf],
  }, { ensureSystem: false });
  const user = built.messages.at(-1);
  const gemini = plain(openaiContentToGeminiParts(user.content));
  assert.equal(gemini[0].text, 'Check both');
  assert.equal(gemini[1].inline_data.mime_type, 'image/png');
  assert.equal(gemini[1].inline_data.data, b64('image-bytes'));
  assert.equal(gemini[2].inline_data.mime_type, 'application/pdf');
  assert.equal(gemini[2].inline_data.data, pdf.base64);
});

test('does not add a second image when content and top-level attachment are merged once', () => {
  const built = buildMiniAppAiMessages({
    messages: [{ role: 'user', content: [{ type: 'text', text: 'Compare' }, image] }],
    attachments: [image],
  }, { ensureSystem: false });
  const user = built.messages.at(-1);
  assert.equal(user.content.filter(p => p.type === 'image_url').length, 2);
  assert.equal(built.stats.images, 2);
});

test('agent uses shared normalization and caches rich OAI user content across rounds', () => {
  const agentStart = html.indexOf("        case 'ai.agent': {");
  const agentEnd = html.indexOf("        case 'ai.chatStream': {", agentStart);
  assert.notEqual(agentStart, -1);
  assert.notEqual(agentEnd, -1);
  const agent = html.slice(agentStart, agentEnd);
  assert.match(agent, /buildMiniAppAiMessages\(\{[\s\S]*?attachments:\s*params\.attachments\s*\|\|\s*params\.files\s*\|\|\s*params\.images/);
  assert.match(agent, /\},\s*\{\s*ensureSystem:\s*false\s*\}\)/);
  assert.match(agent, /const oaiContentCache = new WeakMap\(\)/);
  assert.match(agent, /oaiContentCache\.has\(m\)/);
  assert.match(agent, /oaiContentCache\.set\(m, cp\)/);
});

console.log(`\n${passed} attachment regression tests passed.`);
