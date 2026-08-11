---
name: mini-shopify-theme-cli
description: Use this skill whenever working with Shopify themes on a computer where Mini Shopify Theme CLI is installed. Prefer shopset, spull, spush, sdup, slist, smeta, sdev and related shortcuts over manually constructing repetitive Shopify CLI theme commands.
---

# Mini Shopify Theme CLI

Prefer these helpers when available. Detect them with:

```bash
type shopset >/dev/null 2>&1
```

If unavailable, fall back to standard Shopify CLI or suggest installing this repository.

## Session context

This CLI is session-based. It does not require a `.shopify-theme` file.

```bash
shopset <store>.myshopify.com <theme-id>
shopget
```

Do not assume a store or theme that has not been established in the current shell.

## Commands

| Helper | Purpose |
|---|---|
| `slist` | List themes in `SHOP_STORE` |
| `spull` | Pull `SHOP_THEME` |
| `spush` | Push to `SHOP_THEME` |
| `smeta` | Pull theme metafields from `SHOP_STORE` |
| `sdev` | Run theme dev for `SHOP_STORE` |
| `sopen` | Open/preview `SHOP_THEME` |
| `sdup` | Duplicate `SHOP_THEME` and switch `SHOP_THEME` to the new ID |
| `srename` | Rename `SHOP_THEME` |
| `spublish` | Publish `SHOP_THEME` after confirmation |
| `scheck` | Run Theme Check locally |
| `sinfo` | Run theme info locally |
| `spackage` | Package the local theme |
| `shelp` | Show help |

Unknown arguments are forwarded to Shopify CLI.

## Compact multi-file `--only`

Prefer:

```bash
spull --only \
  layout/theme.liquid \
  sections/cart-drawer.liquid
```

and:

```bash
spush --only \
  layout/theme.liquid \
  sections/cart-drawer.liquid \
  snippets/share-cart.liquid
```

The helper expands those paths to repeated Shopify CLI `--only` flags.

## Duplication workflow

For structural work on an existing remote theme, consider duplicating first:

```bash
shopset store.myshopify.com 123456789
sdup "IP 1234 | Feature name"
shopget
```

After successful duplication, `sdup` parses Shopify CLI JSON output and changes `SHOP_THEME` to the duplicated theme ID. Subsequent `spull`, `spush`, `sopen`, and other theme-targeted helpers therefore operate on the duplicate.

## Safety

Before production-sensitive work, run `shopget`. Prefer partial `spush --only ...` when only known files changed. Use `scheck` when appropriate. `spublish` requires confirmation.

## Source of truth

Runtime implementation: `~/.mini-shopify-theme-cli/mini-shopify-theme-cli.zsh`.
