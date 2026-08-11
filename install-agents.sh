#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/.mini-shopify-theme-cli"
mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/skill"
cp -R "$REPO_DIR/skill" "$INSTALL_DIR/skill"

CODEX_SKILL_DIR="${HOME}/.agents/skills/mini-shopify-theme-cli"
mkdir -p "$(dirname "$CODEX_SKILL_DIR")"
rm -rf "$CODEX_SKILL_DIR"
ln -s "$INSTALL_DIR/skill" "$CODEX_SKILL_DIR"
echo "✓ Skill instalada para Codex: $CODEX_SKILL_DIR"

CLAUDE_DIR="${HOME}/.claude"
CLAUDE_MD="${CLAUDE_DIR}/CLAUDE.md"
CLAUDE_IMPORT='@~/.mini-shopify-theme-cli/skill/SKILL.md'
mkdir -p "$CLAUDE_DIR"
touch "$CLAUDE_MD"
if ! grep -Fq "$CLAUDE_IMPORT" "$CLAUDE_MD"; then
  printf '\n# Mini Shopify Theme CLI\n%s\n' "$CLAUDE_IMPORT" >> "$CLAUDE_MD"
  echo "✓ Import global agregado a Claude Code: $CLAUDE_MD"
else
  echo "✓ Claude Code ya tenía la importación global"
fi

echo "✓ Integración para agentes terminada. Reinicia la sesión del agente si fuera necesario."
