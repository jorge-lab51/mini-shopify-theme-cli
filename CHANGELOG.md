# Changelog

## 0.2.0 - 2026-11-04

- `shopset` accepts the store prefix (`example`) and normalizes it to `example.myshopify.com`. It also accepts `https://` URLs with an optional `/admin`. Custom domains are rejected with a clear message.
- `shopset <store>` without a theme sets only the store and clears `SHOP_THEME`. Theme-targeted helpers explain how to pick a theme.
- `install.sh --link` installs symlinks to the repository instead of copies (development mode). `install-agents.sh` keeps that link instead of replacing it with a copy, and switching between copy and link modes works in both directions.
- Skill: guidance for agent shells (chain `shopset` with the command, carry the `sdup` ID forward, never bypass `spublish`).
- Tests: broader `tests/smoke.zsh` (with a mocked Shopify CLI) and new `tests/install.sh` (installers against a temporary `HOME`).
- Removed the `MINI_SHOPIFY_THEME_CLI_LOADED` load guard (fix for terminals dying).

## 0.1.0 - 2026-08-11

- Session context via `shopset` / `shopget`.
- Daily helpers: `slist`, `spull`, `spush`, `smeta`, `sdev`, `sopen`.
- `sdup` with automatic `SHOP_THEME` update from Shopify CLI JSON.
- `srename`, `spublish`, `scheck`, `sinfo`, `spackage`, `shelp`.
- Compact multi-file `--only` syntax.
- Install/uninstall scripts and agent integration.
