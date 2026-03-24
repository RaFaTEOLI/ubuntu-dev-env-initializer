#!/usr/bin/env bash
# Purpose: Dry-run helper — prints detected INSTALL_* env vars and which template files
#          main.sh would source. Does not install anything.
#
# Usage:
#   ./generate-preview.sh
#   INSTALL_SHELL=zsh INSTALL_EXTRAS=docker,starship ./generate-preview.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES="${ROOT}/templates"

: "${INSTALL_SHELL:=}"
: "${INSTALL_TERMINAL:=}"
: "${INSTALL_RUNTIME:=}"
: "${INSTALL_PKG_MANAGER:=}"
: "${INSTALL_EDITOR:=}"
: "${INSTALL_EXTRAS:=}"
: "${INSTALL_BROWSER:=chrome}"

empty_to_null() {
  local v="${1:-}"
  if [[ -z "${v}" || "${v}" == "none" ]]; then
    printf '%s' "—"
  else
    printf '%s' "${v}"
  fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Linux Dev Wizard — install preview (no changes applied)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
printf "%-22s %s\n" "INSTALL_SHELL" "$(empty_to_null "${INSTALL_SHELL}")"
printf "%-22s %s\n" "INSTALL_TERMINAL" "$(empty_to_null "${INSTALL_TERMINAL}")"
printf "%-22s %s\n" "INSTALL_RUNTIME" "$(empty_to_null "${INSTALL_RUNTIME}")"
printf "%-22s %s\n" "INSTALL_PKG_MANAGER" "$(empty_to_null "${INSTALL_PKG_MANAGER}")"
printf "%-22s %s\n" "INSTALL_EDITOR" "$(empty_to_null "${INSTALL_EDITOR}")"
printf "%-22s %s\n" "INSTALL_EXTRAS" "$(empty_to_null "${INSTALL_EXTRAS}")"
printf "%-22s %s\n" "INSTALL_BROWSER" "$(empty_to_null "${INSTALL_BROWSER}")"
echo
echo "Entry point (run this on the target machine):"
echo "  ${TEMPLATES}/main.sh"
echo
echo "Modules main.sh would source (after base.sh), in order:"

declare -a ORDERED=()

append_file() {
  local f="$1"
  ORDERED+=("${f}")
}

append_file "${TEMPLATES}/base.sh"

case "${INSTALL_SHELL}" in
  zsh) append_file "${TEMPLATES}/shell/zsh.sh" ;;
  fish) append_file "${TEMPLATES}/shell/fish.sh" ;;
  bash) append_file "${TEMPLATES}/shell/bash.sh" ;;
esac

case "${INSTALL_TERMINAL}" in
  wezterm) append_file "${TEMPLATES}/terminal/wezterm.sh" ;;
  kitty) append_file "${TEMPLATES}/terminal/kitty.sh" ;;
  alacritty) append_file "${TEMPLATES}/terminal/alacritty.sh" ;;
  hyper) append_file "${TEMPLATES}/terminal/hyper.sh" ;;
esac

case "${INSTALL_RUNTIME}" in
  bun) append_file "${TEMPLATES}/runtime/bun.sh" ;;
  node) append_file "${TEMPLATES}/runtime/node-nvm.sh" ;;
  deno) append_file "${TEMPLATES}/runtime/deno.sh" ;;
esac

case "${INSTALL_PKG_MANAGER}" in
  pnpm) append_file "${TEMPLATES}/pkg-manager/pnpm.sh" ;;
  bun) append_file "${TEMPLATES}/pkg-manager/bun-pm.sh" ;;
  yarn) append_file "${TEMPLATES}/pkg-manager/yarn-berry.sh" ;;
  npm) append_file "${TEMPLATES}/pkg-manager/npm.sh" ;;
esac

case "${INSTALL_EDITOR}" in
  vscode) append_file "${TEMPLATES}/editor/vscode.sh" ;;
  neovim) append_file "${TEMPLATES}/editor/neovim-lazy.sh" ;;
  helix) append_file "${TEMPLATES}/editor/helix.sh" ;;
  cursor) append_file "${TEMPLATES}/editor/cursor.sh" ;;
esac

if [[ -n "${INSTALL_EXTRAS}" && "${INSTALL_EXTRAS}" != "none" ]]; then
  _ex="${INSTALL_EXTRAS//[[:space:]]/}"
  IFS=',' read -r -a _arr <<< "${_ex}"
  for _e in "${_arr[@]}"; do
    [[ -z "${_e}" ]] && continue
    case "${_e}" in
      docker) append_file "${TEMPLATES}/common/docker.sh" ;;
      git) append_file "${TEMPLATES}/common/git.sh" ;;
      starship) append_file "${TEMPLATES}/common/starship.sh" ;;
      nerd-fonts|nerdfonts) append_file "${TEMPLATES}/common/nerd-fonts.sh" ;;
      tailscale) append_file "${TEMPLATES}/common/extras-tailscale.sh" ;;
      1password-cli|1password) append_file "${TEMPLATES}/common/extras-1password-cli.sh" ;;
      rustup) append_file "${TEMPLATES}/common/extras-rustup.sh" ;;
      go|golang) append_file "${TEMPLATES}/common/extras-go.sh" ;;
      python|uv) append_file "${TEMPLATES}/common/extras-python.sh" ;;
      postman) append_file "${TEMPLATES}/common/extras-postman.sh" ;;
      insomnia) append_file "${TEMPLATES}/common/extras-insomnia.sh" ;;
      browser) append_file "${TEMPLATES}/common/extras-browser.sh" ;;
      chrome|edge|firefox|chromium) append_file "${TEMPLATES}/common/extras-browser.sh" ;;
      user-sudo|sudo-group) append_file "${TEMPLATES}/common/extras-user-sudo.sh" ;;
      docker-compose) echo "  (note: extra 'docker-compose' → use 'docker' for compose v2 plugin)" ;;
      *) echo "  (unknown extra: ${_e})" ;;
    esac
  done
fi

# Dedupe while preserving order
declare -A SEEN=()
i=1
for f in "${ORDERED[@]}"; do
  if [[ -z "${SEEN[$f]:-}" ]]; then
    SEEN[$f]=1
    printf '  %2d. %s\n' "${i}" "${f}"
    ((i++)) || true
  fi
done

echo
echo "To generate a single script later: concatenate these files or run main.sh on Ubuntu/Debian."
echo "Templating placeholders (e.g. {{INSTALL_SHELL}}) are left for envsubst / JS replacement."
