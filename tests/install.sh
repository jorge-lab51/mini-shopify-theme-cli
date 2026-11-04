#!/usr/bin/env bash
# Prueba install.sh, install-agents.sh y uninstall.sh con un HOME temporal.
# Nunca toca el HOME real.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT
export HOME="$TEST_HOME"

INSTALL_DIR="$HOME/.mini-shopify-theme-cli"
INSTALLED_ZSH="$INSTALL_DIR/mini-shopify-theme-cli.zsh"
INSTALLED_SKILL="$INSTALL_DIR/skill"
CODEX_SKILL="$HOME/.agents/skills/mini-shopify-theme-cli"
REPO_ZSH="$ROOT_DIR/src/mini-shopify-theme-cli.zsh"
REPO_SKILL="$ROOT_DIR/skill"

fail() { echo "FAIL: $1"; exit 1; }
quiet() { "$@" >/dev/null; }
repo_checksum() { (cd "$ROOT_DIR" && find src skill -type f | sort | xargs shasum | shasum); }
expect_link() { [[ -L "$1" && "$(readlink "$1")" == "$2" ]] || fail "expected link: $1 -> $2"; }
expect_copy() {
  [[ -e "$1" && ! -L "$1" ]] || fail "expected copy: $1"
  diff -rq "$2" "$1" >/dev/null || fail "copy differs from repo: $1"
}
expect_one_zshrc_line() {
  [[ "$(grep -c 'mini-shopify-theme-cli.zsh' "$HOME/.zshrc")" == 1 ]] || fail "expected exactly one source line in .zshrc"
}

repo_before="$(repo_checksum)"

# Copia (modo por defecto)
quiet "$ROOT_DIR/install.sh"
expect_copy "$INSTALLED_ZSH" "$REPO_ZSH"
expect_copy "$INSTALLED_SKILL" "$REPO_SKILL"
expect_one_zshrc_line

# Copia -> enlace
quiet "$ROOT_DIR/install.sh" --link
expect_link "$INSTALLED_ZSH" "$REPO_ZSH"
expect_link "$INSTALLED_SKILL" "$REPO_SKILL"
expect_one_zshrc_line
zsh -fc 'source "$HOME/.mini-shopify-theme-cli/mini-shopify-theme-cli.zsh" && type shopset' >/dev/null \
  || fail "helpers do not load through the link"

# install-agents.sh mantiene el enlace
quiet "$ROOT_DIR/install-agents.sh"
expect_link "$INSTALLED_SKILL" "$REPO_SKILL"
expect_link "$CODEX_SKILL" "$INSTALLED_SKILL"
[[ -f "$CODEX_SKILL/SKILL.md" ]] || fail "Codex skill not readable"
grep -Fqx '@~/.mini-shopify-theme-cli/skill/SKILL.md' "$HOME/.claude/CLAUDE.md" || fail "Claude import missing"

# Enlace -> enlace (idempotente)
quiet "$ROOT_DIR/install.sh" --link
expect_link "$INSTALLED_ZSH" "$REPO_ZSH"
expect_one_zshrc_line

# Enlace -> copia
quiet "$ROOT_DIR/install.sh"
expect_copy "$INSTALLED_ZSH" "$REPO_ZSH"
expect_copy "$INSTALLED_SKILL" "$REPO_SKILL"
quiet "$ROOT_DIR/install-agents.sh"
expect_copy "$INSTALLED_SKILL" "$REPO_SKILL"

# Desinstalar desde modo enlace no toca el repo
quiet "$ROOT_DIR/install.sh" --link
quiet "$ROOT_DIR/install-agents.sh"
quiet "$ROOT_DIR/uninstall.sh"
[[ ! -e "$INSTALL_DIR" && ! -L "$INSTALL_DIR" ]] || fail "install dir not removed"
[[ ! -e "$CODEX_SKILL" && ! -L "$CODEX_SKILL" ]] || fail "Codex skill link not removed"
if grep -Fq 'mini-shopify-theme-cli' "$HOME/.zshrc"; then fail ".zshrc line not removed"; fi
if grep -Fq 'mini-shopify-theme-cli' "$HOME/.claude/CLAUDE.md"; then fail "Claude import not removed"; fi

[[ "$(repo_checksum)" == "$repo_before" ]] || fail "repository files changed"

echo "OK: install tests passed"
