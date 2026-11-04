# Agent instructions

Runtime source of truth: `src/mini-shopify-theme-cli.zsh`.
Agent behavior documentation: `skill/SKILL.md`.
Human documentation: `README.md`.

When changing a helper, update relevant documentation in the same change.

- Target shell: zsh.
- Preserve forwarding of unknown Shopify CLI flags.
- Keep `shopset` session-based; do not require per-project config.
- `shopset` normalizes the store to `<handle>.myshopify.com` and rejects custom domains; `shopset <store>` without a theme must clear `SHOP_THEME`.
- Keep compact multi-file `--only` for `spull` and `spush`.
- After successful `sdup`, `SHOP_THEME` must point to the new theme ID.
- Keep confirmation for `spublish`.
- Do not add destructive delete helpers without explicit confirmation and clear store/theme display.
- `install.sh` copies by default; `--link` (symlinks to the repository) stays opt-in. `install-agents.sh` must not replace a linked skill with a copy.

## Testing changes

- Run `zsh tests/smoke.zsh` and `bash tests/install.sh`.
- The helpers already loaded in your shell may be an older version (the installed copy, or a snapshot taken when the agent session started). Test the working tree by sourcing it in the same command: `zsh -c 'source src/mini-shopify-theme-cli.zsh && ...'`.
- Never run the installers against the real `HOME` to test them; `tests/install.sh` uses a temporary `HOME`.
