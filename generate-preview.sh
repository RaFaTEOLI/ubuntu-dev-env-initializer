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
source "${TEMPLATES}/registry.sh"

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

declare -a LDW_PLAN_FILES=()
declare -a LDW_PLAN_CALLS=()
ldw_registry_plan_modules "${TEMPLATES}"

printf '  %2d. %s\n' 1 "${TEMPLATES}/base.sh"
i=2
for f in "${LDW_PLAN_FILES[@]}"; do
  printf '  %2d. %s\n' "${i}" "${f}"
  ((i++)) || true
done

echo
echo "To generate a single script later: concatenate these files or run main.sh on Ubuntu/Debian."
echo "Templating placeholders (e.g. {{INSTALL_SHELL}}) are left for envsubst / JS replacement."
