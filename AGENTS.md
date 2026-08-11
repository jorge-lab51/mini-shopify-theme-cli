# Agent instructions

Runtime source of truth: `src/mini-shopify-theme-cli.zsh`.
Agent behavior documentation: `skill/SKILL.md`.
Human documentation: `README.md`.

When changing a helper, update relevant documentation in the same change.

- Target shell: zsh.
- Preserve forwarding of unknown Shopify CLI flags.
- Keep `shopset` session-based; do not require per-project config.
- Keep compact multi-file `--only` for `spull` and `spush`.
- After successful `sdup`, `SHOP_THEME` must point to the new theme ID.
- Keep confirmation for `spublish`.
- Do not add destructive delete helpers without explicit confirmation and clear store/theme display.
