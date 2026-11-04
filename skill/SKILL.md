---
name: mini-shopify-theme-cli
description: Use this skill whenever working with Shopify themes on a computer where Mini Shopify Theme CLI is installed. Prefer shopset, spull, spush, sdup, slist, smeta, sdev and related shortcuts over manually constructing repetitive Shopify CLI theme commands.
---

# Mini Shopify Theme CLI

Prefer these helpers when available. Detect them with:

```bash
type shopset >/dev/null 2>&1
```

If unavailable, see "Agent shells" below before falling back to standard Shopify CLI or suggesting installing this repository.

## Session context

This CLI is session-based. It does not require a `.shopify-theme` file.

```bash
shopset <store> <theme-id>
shopget
```

`<store>` can be the store prefix (`example`), the myshopify domain (`example.myshopify.com`) or its URL (`https://example.myshopify.com/admin`). `shopset` always stores it as `example.myshopify.com`. A store's custom domain (for example `example.com`) is rejected: ask the user for the `.myshopify.com` domain, shown in the Shopify admin under Settings > Domains.

To pick a theme, set only the store first. This clears any previous `SHOP_THEME`:

```bash
shopset example
slist
shopset example 123456789
```

Do not assume a store or theme that has not been established in the current shell.

## Agent shells

Agent tools often run each command in a fresh shell. `SHOP_STORE` and `SHOP_THEME` do not survive between commands, so:

- Put `shopset` and the helper in the same command:

  ```bash
  shopset example 123456789 && spull --only sections/header.liquid
  ```

- If `type shopset` fails, the helpers are not loaded (non-interactive shells often skip `~/.zshrc`). Load them in the same command. They require zsh, so wrap the command in `zsh -c '...'` if the agent shell is bash:

  ```bash
  source ~/.mini-shopify-theme-cli/mini-shopify-theme-cli.zsh && shopset example 123456789 && slist
  ```

- `sdup` switches `SHOP_THEME` only for the rest of that command. Read the new ID from the `ID:` line of its output, tell the user, and use it in later commands (`shopset example <new-id> && spull`). Never fall back to the original theme ID after duplicating.
- `spublish` needs interactive confirmation and cancels in a non-interactive shell. Do not bypass it: do not pipe `y` into it and do not call `shopify theme publish` directly. Ask the user to run `spublish` in their own terminal.

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
shopset example 123456789
sdup "IP 1234 | Feature name"
shopget
```

After successful duplication, `sdup` parses Shopify CLI JSON output and changes `SHOP_THEME` to the duplicated theme ID. Subsequent `spull`, `spush`, `sopen`, and other theme-targeted helpers in the same shell therefore operate on the duplicate. In agent shells, carry the new ID forward explicitly (see "Agent shells").

## Safety

Before production-sensitive work, confirm the store and theme: `shopset` and `shopget` print them (in agent shells, check the output of the same command). Prefer partial `spush --only ...` when only known files changed. Use `scheck` when appropriate. `spublish` requires confirmation.

## Source of truth

Runtime implementation: `~/.mini-shopify-theme-cli/mini-shopify-theme-cli.zsh` (a symlink to the repository when installed with `./install.sh --link`).
