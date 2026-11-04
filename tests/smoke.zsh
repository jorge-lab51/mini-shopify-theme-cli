#!/usr/bin/env zsh
set -e
ROOT_DIR="${0:A:h:h}"
source "$ROOT_DIR/src/mini-shopify-theme-cli.zsh"
fail() { echo "FAIL: $1"; exit 1; }

# Shopify CLI simulado: guarda los argumentos de la última llamada.
shopify() { SHOPIFY_CALL="$*"; }

# shopset con dominio completo
shopset test-store.myshopify.com 123 >/dev/null
[[ "$SHOP_STORE" == "test-store.myshopify.com" ]] || fail "SHOP_STORE"
[[ "$SHOP_THEME" == "123" ]] || fail "SHOP_THEME"

# Normalización de la tienda
for input in azaleiacl AzaleiaCL " azaleiacl " azaleiacl.myshopify.com \
  https://azaleiacl.myshopify.com/admin http://AZALEIACL.myshopify.com/; do
  _shopify_normalize_store "$input" || fail "normalize rejected: $input"
  [[ "$REPLY" == "azaleiacl.myshopify.com" ]] || fail "normalize: $input -> $REPLY"
done
for input in azaleia.cl -bad bad- "a b" admin.shopify.com/store/azaleiacl \
  azaleiacl.myshopify.com/admin/themes; do
  if _shopify_normalize_store "$input" >/dev/null; then fail "normalize accepted: $input"; fi
done

# shopset con prefijo
shopset azaleiacl 456 >/dev/null
[[ "$SHOP_STORE" == "azaleiacl.myshopify.com" ]] || fail "shopset prefix store"
[[ "$SHOP_THEME" == "456" ]] || fail "shopset prefix theme"

# Tienda inválida: el contexto anterior se mantiene
if shopset azaleia.cl 999 >/dev/null; then fail "shopset accepted custom domain"; fi
[[ "$SHOP_STORE" == "azaleiacl.myshopify.com" && "$SHOP_THEME" == "456" ]] || fail "context changed after invalid shopset"

# Solo tienda: borra el theme anterior y bloquea comandos que necesitan theme
shopset other-store >/dev/null
[[ "$SHOP_STORE" == "other-store.myshopify.com" ]] || fail "store-only SHOP_STORE"
[[ -z "${SHOP_THEME:-}" ]] || fail "store-only should clear SHOP_THEME"
SHOPIFY_CALL=""
if spull >/dev/null; then fail "spull ran without theme"; fi
[[ -z "$SHOPIFY_CALL" ]] || fail "spull called shopify without theme"
slist >/dev/null || fail "slist with store only"
[[ "$SHOPIFY_CALL" == "theme list -s other-store.myshopify.com" ]] || fail "slist call: $SHOPIFY_CALL"

# --only compacto
_shopify_theme_args --only layout/theme.liquid sections/header.liquid --strict
[[ "${SHOPIFY_THEME_ARGS[1]}" == "--only" ]] || fail "first --only"
[[ "${SHOPIFY_THEME_ARGS[2]}" == "layout/theme.liquid" ]] || fail "first path"
[[ "${SHOPIFY_THEME_ARGS[3]}" == "--only" ]] || fail "second --only"
[[ "${SHOPIFY_THEME_ARGS[4]}" == "sections/header.liquid" ]] || fail "second path"
[[ "${SHOPIFY_THEME_ARGS[5]}" == "--strict" ]] || fail "forwarded flag"

# spull pasa tienda, theme, --only expandido y flags extra
shopset azaleiacl 456 >/dev/null
spull --only a.liquid b.liquid --nodelete
[[ "$SHOPIFY_CALL" == "theme pull -s azaleiacl.myshopify.com -t 456 --only a.liquid --only b.liquid --nodelete" ]] || fail "spull call: $SHOPIFY_CALL"

echo "OK: smoke tests passed"
