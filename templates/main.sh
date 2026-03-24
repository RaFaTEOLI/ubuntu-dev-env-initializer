#!/usr/bin/env bash
# Purpose: Linux Dev Wizard — entry point. Sources base.sh, then conditionally sources
#          shell / terminal / runtime / package manager / editor / extras from env vars.
#
# Module layout (all under templates/): base.sh, shell/*, terminal/*, runtime/*,
# pkg-manager/*, editor/*, common/* — driven by INSTALL_* env vars (see below).
#
# Configuration: set environment variables before running, e.g.:
#   INSTALL_SHELL=zsh INSTALL_TERMINAL=wezterm INSTALL_RUNTIME=bun \
#   INSTALL_PKG_MANAGER=pnpm INSTALL_EDITOR=vscode \
#   INSTALL_EXTRAS=docker,starship,nerd-fonts,postman,insomnia,chrome,git ./main.sh
#
# Browsers: use extras chrome | edge | firefox | chromium, or \`browser\` with INSTALL_BROWSER=chrome|...
#
# Templating placeholders for generated bundles: {{INSTALL_SHELL}}, {{INSTALL_TERMINAL}},
# {{INSTALL_RUNTIME}}, {{INSTALL_PKG_MANAGER}}, {{INSTALL_EDITOR}}, {{INSTALL_EXTRAS}}

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LDW_TEMPLATE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=base.sh
source "${SCRIPT_DIR}/base.sh"
# shellcheck source=registry.sh
source "${SCRIPT_DIR}/registry.sh"

# Defaults are empty = skip optional sections (no hidden installs).
: "${INSTALL_SHELL:=}"
: "${INSTALL_TERMINAL:=}"
: "${INSTALL_RUNTIME:=}"
: "${INSTALL_PKG_MANAGER:=}"
: "${INSTALL_EDITOR:=}"
: "${INSTALL_EXTRAS:=}"
: "${INSTALL_BROWSER:=chrome}"

export INSTALL_SHELL INSTALL_TERMINAL INSTALL_RUNTIME INSTALL_PKG_MANAGER INSTALL_EDITOR INSTALL_EXTRAS INSTALL_BROWSER

ldw_log "Linux Dev Wizard — starting"
ldw_log "Choices: shell=${INSTALL_SHELL:-∅} terminal=${INSTALL_TERMINAL:-∅} runtime=${INSTALL_RUNTIME:-∅} pkg=${INSTALL_PKG_MANAGER:-∅} editor=${INSTALL_EDITOR:-∅} extras=${INSTALL_EXTRAS:-∅} browser=${INSTALL_BROWSER:-∅}"

ldw_require_sudo

# --- Core bootstrap: curl + ca certs (needed by many installers) ---
if ldw_have_apt; then
  ldw_apt_install ca-certificates curl gnupg lsb-release
fi

declare -a LDW_PLAN_FILES=()
declare -a LDW_PLAN_CALLS=()
ldw_registry_plan_modules "${SCRIPT_DIR}"

if [[ "${#LDW_PLAN_CALLS[@]}" -eq 0 ]]; then
  ldw_log "No optional modules selected."
else
  ldw_log "Selected modules: ${#LDW_PLAN_CALLS[@]}"
fi

for _ldw_file in "${LDW_PLAN_FILES[@]}"; do
  # shellcheck source=/dev/null
  source "${_ldw_file}"
done

for _ldw_call in "${LDW_PLAN_CALLS[@]}"; do
  "${_ldw_call}"
done

if ldw_have_apt; then
  ldw_apt_clean
fi

ldw_log "Linux Dev Wizard — finished successfully."
