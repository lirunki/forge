#!/usr/bin/env node
'use strict';

// Contract checks for the Forge Chat sample's host-managed agent migration.
// Run with: node tests/forge-llm-chat-agent.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');

const sample = fs.readFileSync('samples/Forge_LLM_Chat.html', 'utf8');
const sourceHost = fs.readFileSync('www/index.html', 'utf8');
const androidHost = fs.readFileSync('android/app/src/main/assets/public/index.html', 'utf8');
let passed = 0;
function test(name, fn) {
  fn();
  passed++;
  console.log('✓ ' + name);
}

test('chat delegates to ForgeHost.ai.agent with host registry tool selection', () => {
  assert.match(sample, /h\.ai\.agent\(options\)/);
  assert.match(sample, /tools:\s*\{\s*preset:\s*'selected',\s*names:\s*toolNames\s*\}/);
  assert.match(sample, /riskMax:\s*toolSettings\.riskMax\s*\|\|\s*'safe'/);
  assert.match(sample, /maxRounds:\s*5/);
  assert.match(sample, /attachments:\s*attachments/);
  assert.match(sample, /onToolCall:\s*function\s*\(info\)/);
  assert.match(sample, /onToolResult:\s*function\s*\(info\)/);
});

test('sample no longer owns a model/tool execution loop', () => {
  const scripts = [...sample.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script\s*>/gi)].map(match => match[1]);
  assert.ok(scripts.length, 'sample should have an inline script');
  for (const script of scripts) new Function(script);
  assert.doesNotMatch(sample, /\.ai\.(?:chat|chatStream)\s*\(/);
  assert.doesNotMatch(sample, /\.tools\.run\s*\(/);
  for (const legacy of ['APP_TOOLS', 'buildPayload', 'callChatSync', 'callChatStream', 'runModelOnce', 'toolResultForModel', 'executeTool', 'uiConfirm']) {
    assert.doesNotMatch(sample, new RegExp('\\b' + legacy + '\\b'), `legacy loop symbol remains: ${legacy}`);
  }
});

test('Stop and New Chat cancel the active host run and reject stale callbacks', () => {
  assert.match(sample, /function cancelActiveAgent\(options\)/);
  assert.match(sample, /h\.ai\.cancel\(run\.id\)/);
  assert.match(sample, /function isCurrentAgentRun\(run\)/);
  assert.match(sample, /btnStop'\)\.onclick = function \(\) \{ cancelActiveAgent\(\{ preservePartial: true \}\); \}/);
  assert.match(sample, /function newChat\(\) \{\s*cancelActiveAgent\(\{ silent: true \}\)/);
});

test('host agent streaming and image generation use the app settings', () => {
  assert.match(sample, /options\.onToken\s*=\s*function\s*\(delta\)/);
  assert.match(sample, /settings\.streamMode !== 'sync'/);
  assert.match(sample, /imageGeneration:\s*\{\s*models:\s*pickImageModelsToTry\(settings\.imageModel\)\s*\}/);
  assert.match(sample, /queueGeneratedImageResult\(info, run\)/);
  assert.match(sample, /await waitForGeneratedImages\(run\)/);
  assert.match(sourceHost, /normalizeAgentImageGenerationConfig\(params\.imageGeneration\)/);
  assert.match(sourceHost, /const configuredModels = policy && policy\.imageGeneration && policy\.imageGeneration\.models/);
});

test('APK host asset includes the same agent and image-generation support', () => {
  assert.equal(androidHost, sourceHost, 'www/index.html must be mirrored to the Android public asset');
});

console.log(`\n${passed} Forge Chat agent contract tests passed.`);
