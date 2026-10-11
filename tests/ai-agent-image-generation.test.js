#!/usr/bin/env node
'use strict';

// Provider/model fallback contract for host-managed image_generate agent runs.
// Run with: node tests/ai-agent-image-generation.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

const html = fs.readFileSync('www/index.html', 'utf8');
const sampleHtml = fs.readFileSync('samples/Forge_LLM_Chat.html', 'utf8');
const start = html.indexOf('    function normalizeAgentImageGenerationConfig(value) {');
const end = html.indexOf('    function toolsGetRegistry()', start);
assert.notEqual(start, -1, 'agent image-generation configuration helper not found');
assert.notEqual(end, -1, 'image-generation helper boundary not found');
const policySymbol = Symbol('agent-run-policy');
let attempts = [];
let successOnAttempt = 4;
const sandbox = {
  AGENT_RUN_POLICY: policySymbol,
  Capacitor: { isNativePlatform: () => false },
  getAiRuntime: () => ({
    providerId: 'openai', key: 'openai-secret', base: 'https://api.openai.test/v1',
    provider: { label: 'OpenAI-compatible' },
  }),
  buildAiRuntime: id => id === 'xai' ? ({
    providerId: 'xai', key: 'xai-secret', base: 'https://api.xai.test/v1',
    provider: { label: 'xAI' },
  }) : null,
  aiFgsAcquire: () => () => {},
  fetch: async (url, options) => {
    const request = { url, body: JSON.parse(options.body) };
    attempts.push(request);
    if (attempts.length < successOnAttempt) {
      return { ok: false, status: 503, text: async () => 'temporary failure' };
    }
    return { ok: true, json: async () => ({ data: [{ url: 'https://images.test/generated.png', revised_prompt: 'a test image' }] }) };
  },
};
vm.runInNewContext(
  html.slice(start, end) + '\nthis.__api = { normalizeAgentImageGenerationConfig, generateImage };',
  sandbox,
  { filename: 'www/index.html' },
);
const { normalizeAgentImageGenerationConfig, generateImage } = sandbox.__api;

const eventStart = html.indexOf('    const AGENT_IMAGE_EVENT_MAX_CHARS =');
const eventEnd = html.indexOf('    function agentModelToolResult(', eventStart);
assert.notEqual(eventStart, -1, 'bounded image event helper not found');
const eventSandbox = { agentBoundToolResult: value => value };
vm.runInNewContext(
  html.slice(eventStart, eventEnd) + '\nthis.__publicImageResult = agentPublicImageResult;',
  eventSandbox,
  { filename: 'www/index.html' },
);

const sampleStart = sampleHtml.indexOf(' function extractImagesFromToolResult(result) {');
const sampleEnd = sampleHtml.indexOf(' async function saveChat()', sampleStart);
assert.notEqual(sampleStart, -1, 'Forge Chat image renderer helpers not found');
const imageDom = {
  createElement: tagName => ({ tagName, children: [], appendChild(node) { this.children.push(node); } }),
  getElementById: () => ({ scrollTop: 0, scrollHeight: 0 }),
};
const sampleSandbox = {
  _inlineCache: {}, document: imageDom,
  fetchAsDataUrl: async () => 'data:image/png;base64,AA==',
  looksLikeImageUrl: url => /\\.(?:png|jpe?g|webp)$/i.test(String(url || '')),
};
vm.runInNewContext(
  sampleHtml.slice(sampleStart, sampleEnd) + '\nthis.__imageApi = { extractImagesFromToolResult, enrichImageToolResult, appendGeneratedImages };',
  sampleSandbox,
  { filename: 'samples/Forge_LLM_Chat.html' },
);
const { extractImagesFromToolResult, enrichImageToolResult, appendGeneratedImages } = sampleSandbox.__imageApi;
const cases = [];
function test(name, fn) { cases.push({ name, fn }); }

const normalized = normalizeAgentImageGenerationConfig({ models: [' model-a ', 'model-b', 'model-a'] });
test('validates and normalizes the ordered image-model fallback list', () => {
  assert.deepEqual(JSON.parse(JSON.stringify(normalized)), { models: ['model-a', 'model-b'] });
  assert.equal(normalizeAgentImageGenerationConfig(null), null);
  assert.throws(() => normalizeAgentImageGenerationConfig({ models: [] }), /must not be empty/);
  assert.throws(() => normalizeAgentImageGenerationConfig({ models: ['bad?model'] }), /invalid imageGeneration model id/);
  assert.throws(() => normalizeAgentImageGenerationConfig({ models: Array(9).fill('model-a') }), /at most 8/);
  assert.throws(() => normalizeAgentImageGenerationConfig({ models: ['model-a'], provider: 'xai' }), /unsupported imageGeneration option/);
});

test('tries configured models on selected provider then xAI fallback in order', async () => {
  attempts = [];
  const runOptions = {};
  runOptions[policySymbol] = { imageGeneration: normalized };
  const result = await generateImage({ prompt: 'draw a small sample', n: 1 }, runOptions);
  assert.deepEqual(attempts.map(a => [a.body.model, a.url]), [
    ['model-a', 'https://api.openai.test/v1/images/generations'],
    ['model-a', 'https://api.xai.test/v1/images/generations'],
    ['model-b', 'https://api.openai.test/v1/images/generations'],
    ['model-b', 'https://api.xai.test/v1/images/generations'],
  ]);
  assert.equal(result.ok, true);
  assert.equal(result.model, 'model-b');
  assert.equal(result.backend, 'xai');
  assert.equal(result.images[0].url, 'https://images.test/generated.png');
});

test('keeps direct host tool calls compatible and rejects a missing prompt', async () => {
  attempts = [];
  successOnAttempt = 1;
  const result = await generateImage({ prompt: 'draw this', model: 'direct-model' }, {});
  assert.equal(attempts[0].body.model, 'direct-model');
  await assert.rejects(() => generateImage({}, {}), /prompt is required/);
});

test('agent image tool passes the run policy to its host-owned implementation', () => {
  assert.match(html, /run:\s*async\s*\(a, opts\)\s*=>\s*generateImage\(a\s*\|\|\s*\{\},\s*opts\s*\|\|\s*\{\}\)/);
  assert.match(html, /runOptions\[AGENT_RUN_POLICY\]\s*=\s*agentToolPolicy/);
  assert.match(html, /agentImageGeneration\s*=\s*normalizeAgentImageGenerationConfig\(params\.imageGeneration\)/);
});

test('bounded host image events retain displayable image URLs and prompts', () => {
  const event = eventSandbox.__publicImageResult({ ok: true, count: 1, model: 'model-a', backend: 'xai', images: [
    { url: 'data:image/png;base64,AA==', revised_prompt: 'tiny picture' },
  ] });
  assert.equal(event.images[0].url, 'data:image/png;base64,AA==');
  assert.equal(event.images[0].revised_prompt, 'tiny picture');
  const tooLarge = eventSandbox.__publicImageResult({ images: [{ url: 'data:image/png;base64,' + 'A'.repeat(2000000) }] });
  assert.equal(tooLarge.imagePayloadOmitted, true);
  assert.equal(tooLarge.images[0].omitted, true);
});

test('Forge Chat inlines and renders host image results', async () => {
  const event = eventSandbox.__publicImageResult({ ok: true, images: [
    { url: 'https://images.test/generated.png', revised_prompt: 'small house' },
  ] });
  const parsed = extractImagesFromToolResult(event);
  const enriched = await enrichImageToolResult({ images: parsed });
  assert.equal(enriched.images.length, 1);
  assert.equal(enriched.images[0].url, 'data:image/png;base64,AA==');
  const bubble = { body: { children: [], appendChild(node) { this.children.push(node); } }, _genImages: [] };
  appendGeneratedImages(bubble, enriched.images, 'Generated image');
  assert.equal(bubble.body.children[0].children[0].textContent, 'Generated image');
  assert.equal(bubble.body.children[0].children[1].src, 'data:image/png;base64,AA==');
  assert.equal(bubble._genImages.length, 1);
});

(async () => {
  for (const { name, fn } of cases) {
    await fn();
    console.log('✓ ' + name);
  }
  console.log(`\n${cases.length} image-generation contract tests passed.`);
})().catch(error => { console.error(error); process.exitCode = 1; });
