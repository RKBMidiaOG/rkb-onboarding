# Onboarding do WhatsApp (RKB Tech Engine) — contexto

Página onde o cliente conecta o WhatsApp dele à RKB pela janela oficial da Meta (Embedded Signup).
Briefing original: `~/Downloads/briefing-onboarding-whatsapp.md` (15/10). Regras gerais: `/Users/rkb/Desktop/RKB/CLAUDE.md`.

## Peças

| Peça | Onde |
|---|---|
| Página | este repositório (`RKBMidiaOG/rkb-onboarding`), serviço `onboarding` no Easypanel → https://onboarding.rkbcompany.solutions |
| App da Meta | "RKB Tech Engine", App ID `1712408040398746`, portfólio RKB Mídia, ainda não publicado |
| Configuração do login (Embedded Signup v4) | `config_id` `1799645611084228` (ativo: Contas do WhatsApp; token de usuário do sistema, 60 dias). O antigo `1096464856625207` era variação "Geral" e **não deve mais ser usado** |
| Automação que recebe a conexão | n8n da RKB, workflow `XHzq9lAj8OOBclp8` "Meta · Conectar cliente (Embedded Signup)", `POST /webhook/meta-conectar` |
| Automação dos eventos do WhatsApp | n8n da RKB, workflow `jqWZsITYZr4WeDL4`, `/webhook/whatsapp-cloud` (ver `Dash/docs/DECISOES.md`, 14/10) |
| Banco | Supabase da RKB: tabelas `meta_conexoes` (token e PIN no cofre criptografado, só a referência na tabela) e `meta_eventos`; função `meta_conexao_registrar` |

## Variáveis do serviço `onboarding` (Easypanel → Environment)

Só valores públicos. App Secret e tokens ficam nas credenciais do n8n.

| Variável | Valor |
|---|---|
| `META_APP_ID` | `1712408040398746` |
| `META_CONFIG_ID` | `1138839448657068` (desde 21/10, token do cliente sem vencimento; antes `1799645611084228`) |
| `META_GRAPH_VERSION` | `v26.0` (padrão se vazio) |
| `ONBOARDING_WEBHOOK_URL` | `https://n8n.rkbcompany.solutions/webhook/meta-conectar` |

Se faltar alguma, a página abre em "manutenção" e não chama a Meta. O `config.js` é gerado por `gerar-config.sh` ao subir o container.

## Decisões e achados

- **19/10 — Página ajustada (passos 1 a 6 do pedido do Kayque):** config em variável de ambiente; Graph API v26.0; Embedded Signup v4 (a versão vem da configuração; `extras` só com `setup` e, na coexistência, `featureType: 'whatsapp_business_app_onboarding'`; `sessionInfoVersion` removido); trata eventos FINISH*, CANCEL e erro; só envia ao n8n com `code` + `waba_id` + `phone_number_id`, senão mostra erro e não salva nada. Simulado localmente nos 6 casos. **No ar em 19/10** (commit `7d4b191`, variáveis cadastradas no serviço `n8n/onboarding` e publicado pelo Easypanel). Para voltar: republicar o commit `dbc3a5c` (antes não havia variáveis).
- **19/10 — Documentação da Meta:** v2 e v3 do Embedded Signup desativadas em 15/10/2026. Coexistência: **não** registrar o número; sincronizar contatos (`POST /{phone_number_id}/smb_app_data`, `sync_type: smb_app_state_sync`) e histórico (`sync_type: history`) em até 24h, uma vez cada; assinar no webhook `account_update`, `history`, `smb_app_state_sync`, `smb_message_echoes`.
- **19/10 — Achado no n8n:** no ar, o nó "Troca code por token" envia a credencial "Meta App Secret RKB" como cabeçalho; a Meta espera `client_secret` como parâmetro da URL. Provável falha na troca. Corrigir junto com a parte do backend.
- **19/10 — Teste real (Kayque, portfólio RKB Midia):** o Chrome estava com a página antiga em cache (abria v23 + config antiga) → servidor passou a mandar `Cache-Control: no-cache` (nginx.conf). Com a página nova (v26, config `1799645611084228`, coexistência), a Meta mostra **"RKB Midia não pode integrar clientes no momento"**. Bloqueio do lado da Meta, não da página. Causas prováveis (relatos da comunidade, não documentação oficial): (1) assistente "Tornar-se Tech Provider" no painel do app não concluído / em análise (DECISOES da Dash, 13/10: selo Tech Provider em análise); (2) falta App Review com acesso avançado a `whatsapp_business_management` e `whatsapp_business_messaging`; (3) a Meta não deixa conectar uma conta do WhatsApp do **mesmo portfólio** dono do app — testar exigiria outro portfólio (o perfil do Kayque está no limite de portfólios). Nada chegou ao n8n nem ao banco.

## Falta (backend, passos 7 a 11)

- n8n: subir para v26.0, corrigir envio do `client_secret`, exigir número também na coexistência, sincronização de contatos e histórico na coexistência.
- Supabase: guardar data de vencimento do token do cliente; aviso antes de vencer (se o token do cliente for necessário depois).
- Confirmar na documentação o modelo de operação como Tech Provider (token permanente do usuário do sistema da RKB × token do cliente).
- Testar só com o portfólio da RKB Mídia. Nunca com cliente em produção (alguns estão na HookCloud).
