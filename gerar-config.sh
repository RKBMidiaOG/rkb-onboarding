#!/bin/sh
# Roda ao subir o container (nginx executa /docker-entrypoint.d/*.sh).
# Gera /config.js a partir das variáveis do serviço no Easypanel.
# Só valores públicos: segredos (App Secret, tokens) ficam no n8n, nunca aqui.
set -eu

OUT=/usr/share/nginx/html/config.js

APP_ID="${META_APP_ID:-}"
CONFIG_ID="${META_CONFIG_ID:-}"
GRAPH_VERSION="${META_GRAPH_VERSION:-v26.0}"
WEBHOOK_URL="${ONBOARDING_WEBHOOK_URL:-}"

# valida o formato para não injetar nada estranho na página
ok=1
printf '%s' "$APP_ID"        | grep -Eq '^[0-9]+$'                       || { echo "config: META_APP_ID ausente ou inválido" >&2; ok=0; }
printf '%s' "$CONFIG_ID"     | grep -Eq '^[0-9]+$'                       || { echo "config: META_CONFIG_ID ausente ou inválido" >&2; ok=0; }
printf '%s' "$GRAPH_VERSION" | grep -Eq '^v[0-9]+\.[0-9]+$'              || { echo "config: META_GRAPH_VERSION inválido" >&2; ok=0; }
printf '%s' "$WEBHOOK_URL"   | grep -Eq '^https://[A-Za-z0-9./_-]+$'     || { echo "config: ONBOARDING_WEBHOOK_URL ausente ou inválido" >&2; ok=0; }

if [ "$ok" = 1 ]; then
  printf 'window.RKB_CONFIG = {"appId":"%s","configId":"%s","graphVersion":"%s","webhookUrl":"%s"};\n' \
    "$APP_ID" "$CONFIG_ID" "$GRAPH_VERSION" "$WEBHOOK_URL" > "$OUT"
else
  # página abre em modo "manutenção" e não chama a Meta
  echo 'window.RKB_CONFIG = {};' > "$OUT"
fi
