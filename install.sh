#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Uso: ./install.sh [--link]

  (sin opciones)  Copia los archivos a ~/.mini-shopify-theme-cli.
  --link          Enlaza esos archivos al repositorio (modo desarrollo):
                  los cambios del repo se aplican con `source ~/.zshrc`, sin reinstalar.
EOF
}

MODE="copy"
for arg in "$@"; do
  case "$arg" in
    --link) MODE="link" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "❌ Opción desconocida: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/.mini-shopify-theme-cli"
ZSHRC="${HOME}/.zshrc"
SOURCE_LINE='source "$HOME/.mini-shopify-theme-cli/mini-shopify-theme-cli.zsh"'

# Reemplaza DEST por una copia de SRC, o por un enlace a SRC en modo --link.
# Borrar antes evita que cp escriba a través de un enlace previo hacia el repo;
# rm nunca sigue un enlace que recibe como argumento, así que el repo no se toca.
install_item() {
  local src="$1" dest="$2"
  rm -rf -- "$dest"
  if [[ "$MODE" == "link" ]]; then
    ln -s "$src" "$dest"
  else
    cp -R "$src" "$dest"
  fi
}

mkdir -p "$INSTALL_DIR"
install_item "$REPO_DIR/src/mini-shopify-theme-cli.zsh" "$INSTALL_DIR/mini-shopify-theme-cli.zsh"
install_item "$REPO_DIR/skill" "$INSTALL_DIR/skill"

touch "$ZSHRC"
if ! grep -Fq "$SOURCE_LINE" "$ZSHRC"; then
  printf '\n# Mini Shopify Theme CLI\n%s\n' "$SOURCE_LINE" >> "$ZSHRC"
  echo "✓ Agregado a ~/.zshrc"
else
  echo "✓ ~/.zshrc ya estaba configurado"
fi

if [[ "$MODE" == "link" ]]; then
  echo "✓ Instalación terminada en modo --link (enlazado a $REPO_DIR)."
  echo "  Los cambios del repo se aplican con: source ~/.zshrc"
  echo "  Si mueves o borras el repo, vuelve a ejecutar ./install.sh --link"
else
  echo "✓ Instalación terminada. Ejecuta: source ~/.zshrc"
fi
echo "  Ayuda: shelp"
echo "  Agentes: ./install-agents.sh"
