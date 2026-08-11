#!/usr/bin/env zsh
set -e
ROOT_DIR="${0:A:h:h}"
source "$ROOT_DIR/src/mini-shopify-theme-cli.zsh"
fail() { echo "FAIL: $1"; exit 1; }
shopset test-store.myshopify.com 123 >/dev/null
[[ "$SHOP_STORE" == "test-store.myshopify.com" ]] || fail "SHOP_STORE"
[[ "$SHOP_THEME" == "123" ]] || fail "SHOP_THEME"
_shopify_theme_args --only layout/theme.liquid sections/header.liquid --strict
[[ "${SHOPIFY_THEME_ARGS[1]}" == "--only" ]] || fail "first --only"
[[ "${SHOPIFY_THEME_ARGS[2]}" == "layout/theme.liquid" ]] || fail "first path"
[[ "${SHOPIFY_THEME_ARGS[3]}" == "--only" ]] || fail "second --only"
[[ "${SHOPIFY_THEME_ARGS[4]}" == "sections/header.liquid" ]] || fail "second path"
[[ "${SHOPIFY_THEME_ARGS[5]}" == "--strict" ]] || fail "forwarded flag"
echo "OK: smoke tests passed"
