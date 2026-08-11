#!/usr/bin/env bash
set -euo pipefail
INSTALL_DIR="${HOME}/.mini-shopify-theme-cli"
ZSHRC="${HOME}/.zshrc"
CODEX_SKILL_DIR="${HOME}/.agents/skills/mini-shopify-theme-cli"
CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
SOURCE_LINE='source "$HOME/.mini-shopify-theme-cli/mini-shopify-theme-cli.zsh"'
CLAUDE_IMPORT='@~/.mini-shopify-theme-cli/skill/SKILL.md'
remove_line() {
  local file="$1" line="$2" tmp
  [[ -f "$file" ]] || return 0
  tmp="$(mktemp)"
  grep -Fvx "$line" "$file" > "$tmp" || true
  mv "$tmp" "$file"
}
remove_line "$ZSHRC" "$SOURCE_LINE"
[[ -L "$CODEX_SKILL_DIR" || -e "$CODEX_SKILL_DIR" ]] && rm -rf "$CODEX_SKILL_DIR"
remove_line "$CLAUDE_MD" "$CLAUDE_IMPORT"
rm -rf "$INSTALL_DIR"
echo "✓ Mini Shopify Theme CLI desinstalado."
