#!/usr/bin/env python3
# One-off: insert chat.fail* i18n keys after chat.forgeFail in all 6 langs.
import re, json

NEW_KEYS = {
  'en': {
    'chat.failNoKey': 'No AI key set for this provider — open AI settings and add one, or run Turnkey setup.',
    'chat.failNetwork': 'Network issue reaching the AI provider. Check your connection and try again. (If Forge was backgrounded, Android may have cut network — keep it open while building.)',
    'chat.failAuth': 'The AI provider rejected the request (error {code}). Your key may be invalid, out of credit, or the model is unavailable — check AI settings.',
    'chat.failServer': 'The AI provider had an error (error {code}). Try again in a moment, or switch providers in AI settings.',
    'chat.failParse': "The model didn't return a buildable app this time (no JSON payload). Try rephrasing your request, or tap Create again — it often works on retry.",
  },
  'es': {
    'chat.failNoKey': 'No hay clave de IA para este proveedor — abre Ajustes de IA y añade una, o usa el ajuste exprés.',
    'chat.failNetwork': 'Problema de red al contactar al proveedor. Revisa tu conexión e inténtalo de nuevo. (Si Forge pasó a segundo plano, Android puede haber cortado la red — mantenla abierta mientras crea).',
    'chat.failAuth': 'El proveedor rechazó la solicitud (error {code}). La clave puede ser inválida, sin crédito o el modelo no disponible — revisa Ajustes de IA.',
    'chat.failServer': 'El proveedor tuvo un error (error {code}). Inténtalo en un momento o cambia de proveedor en Ajustes de IA.',
    'chat.failParse': 'El modelo no devolvió una app construible esta vez (sin JSON). Reformula tu solicitud o pulsa Crear de nuevo — suele funcionar al reintentar.',
  },
  'fr': {
    'chat.failNoKey': "Aucune clé IA pour ce fournisseur — ouvrez les réglages IA et ajoutez-en une, ou lancez l'assistant.",
    'chat.failNetwork': 'Problème réseau vers le fournisseur. Vérifiez votre connexion et réessayez. (Si Forge passait en arrière-plan, Android a pu couper le réseau — gardez-la ouverte pendant la création).',
    'chat.failAuth': 'Le fournisseur a rejeté la requête (erreur {code}). Clé invalide, sans crédit ou modèle indisponible — vérifiez les réglages IA.',
    'chat.failServer': 'Le fournisseur a eu une erreur (erreur {code}). Réessayez dans un instant ou changez de fournisseur dans les réglages IA.',
    'chat.failParse': "Le modèle n'a pas renvoyé d'app constructible cette fois (pas de JSON). Reformulez votre demande ou appuyez à nouveau sur Créer — ça marche souvent au réessai.",
  },
  'pt': {
    'chat.failNoKey': 'Sem chave de IA para este provedor — abra as configurações de IA e adicione uma, ou use o assistente.',
    'chat.failNetwork': 'Problema de rede ao contatar o provedor. Verifique a conexão e tente de novo. (Se o Forge foi para segundo plano, o Android pode ter cortado a rede — mantenha aberto durante a criação).',
    'chat.failAuth': 'O provedor recusou a solicitação (erro {code}). Chave inválida, sem crédito ou modelo indisponível — verifique as configurações de IA.',
    'chat.failServer': 'O provedor teve um erro (erro {code}). Tente novamente em instantes ou troque de provedor nas configurações de IA.',
    'chat.failParse': 'O modelo não devolveu um app construível desta vez (sem JSON). Reformule o pedido ou toque em Criar de novo — geralmente funciona ao tentar outra vez.',
  },
  'ja': {
    'chat.failNoKey': 'このプロバイダーのAIキーが未設定 — AI設定で追加するか、ターンキーセットアップを実行してください。',
    'chat.failNetwork': 'プロバイダーへのネットワーク接続に問題。接続を確認して再試行してください。（Forgeがバックグラウンド中はAndroidがネットワークを切ることがあります — 作成中は開いたままに）',
    'chat.failAuth': 'プロバイダーがリクエストを拒否しました（エラー{code}）。キーが無効・残高切れ・モデル利用不可の可能性 — AI設定を確認してください。',
    'chat.failServer': 'プロバイダーでエラーが発生（エラー{code}）。しばらくして再試行するか、AI設定でプロバイダーを変更してください。',
    'chat.failParse': 'モデルが今回はJSONを返しませんでした（構築不能）。依頼を言い換えるか、もう一度「作成」をタップ — 再試行で成功することが多いです。',
  },
  'ko': {
    'chat.failNoKey': '이 제공자의 AI 키가 없습니다 — AI 설정에서 추가하거나 턴키 설정을 실행하세요.',
    'chat.failNetwork': 'AI 제공자에 연결하지 못했습니다. 연결을 확인하고 다시 시도하세요. (Forge가 백그라운드에 있으면 Android가 네트워크를 끊을 수 있습니다 — 만드는 동안 열어두세요.)',
    'chat.failAuth': '제공자가 요청을 거부했습니다(오류 {code}). 키가 유효하지 않거나 크레딧이 부족하거나 모델을 사용할 수 없습니다 — AI 설정을 확인하세요.',
    'chat.failServer': '제공자에 오류가 발생했습니다(오류 {code}). 잠시 후 다시 시도하거나 AI 설정에서 제공자를 바꾸세요.',
    'chat.failParse': '모델이 이번에는 JSON을 반환하지 않았습니다(빌드 불가). 요청을 다시 표현하거나 만들기를 다시 누르세요 — 재시도하면 성공하는 경우가 많습니다.',
  },
}

src = open('/data/data/com.termux/files/home/downloads/forge/www/index.html', encoding='utf-8').read()
count = 0
for lang, keys in NEW_KEYS.items():
    ins = '\n'.join('    ' + json.dumps(k, ensure_ascii=False) + ': ' + json.dumps(v, ensure_ascii=False) + ','
                    for k, v in keys.items())
    pat = re.compile(r'(      ' + lang + r': \{\n(?:.*\n)*?    "chat\.forgeFail": [^\n]*\n)')
    m = pat.search(src)
    assert m, lang + ': anchor chat.forgeFail not found'
    src = src[:m.end(1)] + ins + '\n' + src[m.end(1):]
    count += len(keys)
open('/data/data/com.termux/files/home/downloads/forge/www/index.html', 'w', encoding='utf-8').write(src)
print('inserted', count, 'keys across', len(NEW_KEYS), 'langs')
