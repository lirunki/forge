#!/usr/bin/env node
'use strict';

// Contract tests: image_generate is offered/runnable at every riskMax level
// (the riskMax ceiling is exempt), while the per-call confirmation modal and
// "Always allow" memory still apply. Run with: node tests/image-generate-risk.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');

const html = fs.readFileSync('www/index.html', 'utf8');
const tools = fs.readFileSync('docs/tools.md', 'utf8');
let passed = 0;
function test(name, fn) { fn(); passed++; console.log('✓ ' + name); }

test('host registry declares image_generate as a confirm-tier tool', () => {
  const i = html.indexOf("name: 'image_generate'");
  assert.notEqual(i, -1, 'image_generate must be registered');
  const region = html.slice(i, i + 700);
  assert.match(region, /risk:\s*'confirm'/, 'image_generate risk must be confirm');
});

test('a riskMax-ceiling exemption helper exists for image_generate', () => {
  assert.match(html, /function toolRiskCeilingExempt\(name\)/);
  assert.match(html, /return name === 'image_generate';/);
});

test('toolsFilterEntries exempts image_generate from the riskMax ceiling', () => {
  // The catalog filter must NOT drop image_generate when riskMax < confirm.
  assert.match(
    html,
    /if \(!toolRiskCeilingExempt\(e\.name\) && toolRiskRank\(e\.risk\) > maxRank\) return false;/,
    'toolsFilterEntries must exempt image_generate from the riskMax ceiling',
  );
});

test('toolsRun host branch exempts image_generate from the riskMax ceiling', () => {
  const m = html.match(/const entry = HOST_TOOL_REGISTRY\.find\(\(e\) => e\.name === name\);[\s\S]{0,400}if \(!toolRiskCeilingExempt\(name\) && toolRiskRank\(entry\.risk\) > toolRiskRank\(maxRisk\)\)/);
  assert.ok(m, 'toolsRun host branch must exempt image_generate from riskMax');
});

test('toolsRun app-tool branch exempts image_generate from the riskMax ceiling', () => {
  const m = html.match(/const entry = map\.get\(name\);[\s\S]{0,200}if \(!toolRiskCeilingExempt\(name\) && toolRiskRank\(entry\.risk\) > toolRiskRank\(maxRisk\)\)/);
  assert.ok(m, 'toolsRun app-tool branch must exempt image_generate from riskMax');
});

test('the per-call confirmation path for image_generate is preserved', () => {
  // agentConfirmTool still gates confirm-tier tools (returns true for safe,
  // shows a modal for confirm). image_generate stays confirm, so first use
  // still prompts unless "Always allow" remembers it.
  assert.match(html, /async function agentConfirmTool\(name, args, risk/);
  assert.match(html, /if \(rank === toolRiskRank\('safe'\)\) return true;/);
});

test('agentRequestToolAccess auto-allows safe + confirm tiers (image_generate needs no sensitive opt-in)', () => {
  // image_generate is confirm, not sensitive/danger, so it never triggers the
  // sensitive/danger access modal — only the per-call confirm sheet.
  const i = html.indexOf('function agentRequestToolAccess(');
  assert.notEqual(i, -1);
  const region = html.slice(i, i + 600);
  assert.match(region, /risk === 'safe' \|\| risk === 'confirm'/);
});

test('docs note that image_generate is offered at every riskMax level', () => {
  assert.match(
    tools,
    /Offered and runnable at every `riskMax` level.*the per-call host confirmation modal and "Always allow" memory still apply/,
  );
});

console.log('\n' + passed + ' tests passed.');
