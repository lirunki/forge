#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const samplesDir = path.resolve('samples');
const manifest = JSON.parse(fs.readFileSync(path.join(samplesDir, 'manifest.json'), 'utf8'));
let passed = 0;
function test(name, fn) { fn(); passed++; console.log('✓ ' + name); }

test('sample catalog IDs and file paths are unique and safe', () => {
  const ids = manifest.samples.map((sample) => sample.id);
  const files = manifest.samples.map((sample) => sample.file);
  assert.equal(new Set(ids).size, ids.length, 'sample IDs must be unique');
  assert.equal(new Set(files).size, files.length, 'sample HTML files must be unique');
  for (const file of files) {
    assert.equal(path.basename(file), file, 'sample file must stay within samples/: ' + file);
    const html = path.join(samplesDir, file);
    assert.ok(fs.existsSync(html), 'manifest file is missing: ' + file);
    assert.match(fs.readFileSync(html, 'utf8'), /<!doctype html|<html[\s>]/i, 'invalid sample HTML: ' + file);
  }
});

test('manifest contains every demo HTML and no unlisted demo files', () => {
  const listed = manifest.samples.map((sample) => sample.file).sort();
  const present = fs.readdirSync(samplesDir).filter((file) => file.toLowerCase().endsWith('.html')).sort();
  assert.deepEqual(listed, present);
});

test('Agent Task Lab has been removed from the demos', () => {
  assert.ok(!manifest.samples.some((sample) => sample.id === 'forge-agent-task-lab' || sample.file === 'Forge_Agent_Task_Lab.html'));
  assert.ok(!fs.existsSync(path.join(samplesDir, 'Forge_Agent_Task_Lab.html')));
});

console.log('\n' + passed + ' tests passed.');
