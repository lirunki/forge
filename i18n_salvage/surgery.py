"""Regenerate Forge's localization block from the current host source.

The current forge/www/index.html is the canonical HTML source. This script
only replaces the FORGE_I18N block; it does not rebuild or strip unrelated
host code. Existing host translations are used as the baseline so older or
newer keys not present in the recovery dictionaries are preserved.
"""
import importlib.util
import json
import re
from pathlib import Path

SALVAGE_DIR = Path(__file__).resolve().parent
FORGE_ROOT = SALVAGE_DIR.parent
SRC = FORGE_ROOT / 'www/index.html'
OUT = SRC
DICT_DIR = SALVAGE_DIR
LANGS = ['en', 'es', 'fr', 'pt', 'ja', 'ko']
NS_PREFIXES = ('setup.blurb.', 'setup.guide.', 'setup.steps.', 'setup.whyEasy.',
               'setup.keyHint.', 'ai.hint.', 'ai.keyLabel.')

RESTART_HINT = {
    'en': 'Saved — restart Forge to apply.',
    'es': 'Guardado: reinicia Forge para aplicarlo.',
    'fr': 'Enregistré — redémarrez Forge pour l’appliquer.',
    'pt': 'Salvo — reinicie o Forge para aplicar.',
    'ja': '保存しました。Forgeを再起動すると適用されます。',
    'ko': '저장됨 — 적용하려면 Forge를 다시 시작하세요.',
}


def load_dict(lang):
    path = DICT_DIR / f'dict_{lang}.py'
    spec = importlib.util.spec_from_file_location(f'dict_{lang}', path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f'cannot load {path}')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return getattr(module, lang.upper())


def load_current_i18n(text):
    """Parse the existing JSON-compatible FORGE_I18N string values."""
    marker = re.search(r'/\*__I18N_START__\*/(.*?)/\*__I18N_END__\*/', text, re.S)
    assert marker, 'current host is missing the FORGE_I18N markers'
    block = marker.group(1)
    result = {}
    for lang in LANGS:
        section = re.search(rf'\n\s*{lang}:\s*\{{(.*?)\n\s*\}}', block, re.S)
        assert section, f'current host is missing the {lang} dictionary'
        values = {}
        for line in section.group(1).splitlines():
            match = re.match(r'^\s*("(?:\\.|[^"])*")\s*:\s*("(?:\\.|[^"])*")\s*,?\s*$', line)
            if match:
                values[json.loads(match.group(1))] = json.loads(match.group(2))
            elif line.strip():
                raise AssertionError(f'unparsed {lang} dictionary line: {line[:120]}')
        result[lang] = values
    return result


src = SRC.read_text(encoding='utf-8')
orig_len = len(src)
current = load_current_i18n(src)

MOJIBAKE_PAIR = re.compile('[\u00c2\u00c3\u00e2-\u00ef][\u0080-\u00bf]')


def fix_mojibake(value):
    try:
        raw = value.encode('latin-1')
    except UnicodeEncodeError:
        return value
    try:
        return raw.decode('utf-8')
    except UnicodeDecodeError:
        return None if MOJIBAKE_PAIR.search(value) else value


dicts = {}
for lang in LANGS:
    # Start with current host strings, then apply recovered dictionary values.
    merged = {k: v for k, v in current[lang].items() if not k.startswith('gate.')}
    for key, value in load_dict(lang).items():
        if key.startswith('gate.'):
            continue
        fixed = fix_mojibake(value)
        if fixed is None:
            print(f'DROP {lang}:{key} (lossy bytes)')
        else:
            merged[key] = fixed
    merged['about.langRestart'] = RESTART_HINT[lang]
    dicts[lang] = merged

suspect = re.compile(r'\u00c3[\u0080-\u00bf]|\u00e2\u0080[\u0098-\u009d\u0093\u0094]|\u00c2\u00a0')
for lang in LANGS:
    for key in [k for k, value in dicts[lang].items() if suspect.search(value)]:
        print(f'DROP {lang}:{key} (unrepairable)')
        del dicts[lang][key]

en_keys = set(dicts['en'])
for lang in LANGS[1:]:
    extra = set(dicts[lang]) - en_keys
    bad = {key for key in extra if not key.startswith(NS_PREFIXES)}
    assert not bad, f'{lang}: unexpected extra keys {sorted(bad)[:5]}'
    missing = en_keys - set(dicts[lang])
    if missing:
        print(f'NOTE {lang}: {len(missing)} keys fall back to en: {sorted(missing)[:4]}…')


def emit(lang, values):
    body = ',\n'.join(
        f' {json.dumps(key, ensure_ascii=False)}: {json.dumps(value, ensure_ascii=False)}'
        for key, value in sorted(values.items())
    )
    return f' {lang}: {{\n{body}\n}}'


block = (
    ' /*__I18N_START__*/\n'
    ' const FORGE_I18N = {\n'
    + ',\n'.join(emit(lang, dicts[lang]) for lang in LANGS)
    + '\n };\n'
    ' /*__I18N_END__*/'
)
marker = re.compile(r' /\*__I18N_START__\*/.*? /\*__I18N_END__\*/\n', re.S)
match = marker.search(src)
assert match, 'current host is missing the FORGE_I18N markers'
src = src[:match.start()] + block + '\n' + src[match.end():]

assert 'lang-gate' not in src and 'isLangGateActive' not in src
assert 'wireLangGate' not in src and 'forge-lang-gate-done' not in src

OUT.write_text(src, encoding='utf-8')
print(f'OK {orig_len} -> {len(src)} chars ({len(src) - orig_len:+d})')
print('keys per lang:', {lang: len(dicts[lang]) for lang in LANGS})
