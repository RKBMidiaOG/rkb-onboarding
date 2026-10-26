#!/bin/sh
# Roda ao subir o container (nginx executa /docker-entrypoint.d/*.sh).
# Gera /config.js a partir das variáveis do serviço no Easypanel.
# Só valor público: o endereço do motor de conexão (o mesmo do CRM).
# App, configuração da Meta e versão vêm do próprio motor; segredos ficam só no servidor do CRM.
set -eu

OUT=/usr/share/nginx/html/config.js
API_URL="${ONBOARDING_API_URL:-https://crm.rkbcompany.solutions/api/publico}"

if printf '%s' "$API_URL" | grep -Eq '^https://[A-Za-z0-9./_-]+$'; then
  printf 'window.RKB_CONFIG = {"apiUrl":"%s"};\n' "$API_URL" > "$OUT"
else
  echo "config: ONBOARDING_API_URL inválido" >&2
  # página abre em "manutenção" e não chama a Meta
  echo 'window.RKB_CONFIG = {};' > "$OUT"
fi
