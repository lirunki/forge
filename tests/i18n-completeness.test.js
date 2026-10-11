#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const hostPath = path.resolve('www/index.html');
const host = fs.readFileSync(hostPath, 'utf8');
const marker = host.match(/\/\*__I18N_START__\*\/([\s\S]*?)\/\*__I18N_END__\*\//);
assert.ok(marker, 'host must contain the localization block markers');
const block = marker[1];
const languages = ['en', 'es', 'fr', 'pt', 'ja', 'ko'];
const dictionaries = {};

for (const lang of languages) {
  const section = block.match(new RegExp(`\\n\\s*${lang}:\\s*\\{([\\s\\S]*?)\\n\\s*\\}`));
  assert.ok(section, `missing ${lang} dictionary`);
  const values = {};
  for (const line of section[1].split(/\r?\n/)) {
    if (!line.trim()) continue;
    const entry = line.match(/^\s*("(?:\\.|[^"])*")\s*:\s*("(?:\\.|[^"])*")\s*,?\s*$/);
    assert.ok(entry, `unparseable ${lang} translation: ${line}`);
    values[JSON.parse(entry[1])] = JSON.parse(entry[2]);
  }
  dictionaries[lang] = values;
}

const englishKeys = Object.keys(dictionaries.en);
for (const lang of languages) {
  const dict = dictionaries[lang];
  for (const key of englishKeys) {
    assert.ok(Object.hasOwn(dict, key), `${lang} is missing translation key ${key}`);
    assert.ok(dict[key].trim(), `${lang}.${key} must not be empty`);
  }
}
const localizedKeys = Object.keys(dictionaries.es).sort();
for (const lang of languages.slice(1)) {
  assert.deepEqual(Object.keys(dictionaries[lang]).sort(), localizedKeys, `${lang} must keep the same localized key set`);
}

function placeholders(value) {
  return [...value.matchAll(/\{([A-Za-z_][\w.-]*)\}/g)].map((match) => match[1]).sort();
}
for (const lang of languages.slice(1)) {
  for (const key of englishKeys) {
    assert.deepEqual(
      placeholders(dictionaries[lang][key]),
      placeholders(dictionaries.en[key]),
      `${lang}.${key} must preserve English interpolation placeholders`,
    );
  }
}

const staticRefs = new Set();
for (const match of host.matchAll(/\bdata-i18n(?:-[\w-]+)?\s*=\s*["']([^"']+)["']/g)) {
  staticRefs.add(match[1]);
}
for (const match of host.matchAll(/\b(?:t|tf)\(\s*(['"])([^'"]+)\1/g)) {
  staticRefs.add(match[2]);
}
for (const key of staticRefs) {
  if (key.endsWith('.')) continue; // Dynamic translation namespace prefix.
  assert.ok(Object.hasOwn(dictionaries.en, key), `static UI reference ${key} has no English entry`);
}

console.log(`✓ ${languages.length} locales cover ${englishKeys.length} English keys; static UI references and placeholders are valid.`);
