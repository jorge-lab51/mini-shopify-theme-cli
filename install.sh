#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/.mini-shopify-theme-cli"
ZSHRC="${HOME}/.zshrc"
SOURCE_LINE='source "$HOME/.mini-shopify-theme-cli/mini-shopify-theme-cli.zsh"'
mkdir -p "$INSTALL_DIR"
cp "$REPO_DIR/src/mini-shopify-theme-cli.zsh" "$INSTALL_DIR/mini-shopify-theme-cli.zsh"
rm -rf "$INSTALL_DIR/skill"
cp -R "$REPO_DIR/skill" "$INSTALL_DIR/skill"
touch "$ZSHRC"
if ! grep -Fq "$SOURCE_LINE" "$ZSHRC"; then
  printf '\n# Mini Shopify Theme CLI\n%s\n' "$SOURCE_LINE" >> "$ZSHRC"
  echo "✓ Agregado a ~/.zshrc"
else
  echo "✓ ~/.zshrc ya estaba configurado"
fi
echo "✓ Instalación terminada. Ejecuta: source ~/.zshrc"
echo "  Ayuda: shelp"
echo "  Agentes: ./install-agents.sh"
