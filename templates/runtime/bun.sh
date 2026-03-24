#!/usr/bin/env bash
# Purpose: Install the Bun JavaScript runtime (https://bun.sh) if not already present.
#
# Env:
#   BUN_INSTALL — install prefix (default: ~/.bun)
#
# Templating: {{BUN_VERSION}} (optional pin for generated scripts)

ldw_runtime_install_bun() {
  if ldw_command_exists bun; then
    ldw_log "bun already installed: $(command -v bun)"
    return 0
  fi

  ldw_log "Installing Bun"
  : "${BUN_INSTALL:=${LDW_HOME}/.bun}"
  export BUN_INSTALL

  # Official installer; non-interactive
  curl -fsSL https://bun.sh/install | bash

  # Ensure PATH for current session note (user should restart shell)
  if [[ -f "${BUN_INSTALL}/bin/bun" ]]; then
    ldw_log "Bun installed to ${BUN_INSTALL}/bin/bun"
  fi

  # Append to .profile if missing (idempotent line check)
  local profile="${LDW_HOME}/.profile"
  local line="export BUN_INSTALL=\"${BUN_INSTALL}\""
  local path_line='export PATH="$BUN_INSTALL/bin:$PATH"'
  if [[ -f "${profile}" ]]; then
    grep -qF "${line}" "${profile}" 2>/dev/null || echo "${line}" >> "${profile}"
    grep -qF 'BUN_INSTALL/bin' "${profile}" 2>/dev/null || echo "${path_line}" >> "${profile}"
  else
    umask 077
    printf '%s\n%s\n' "${line}" "${path_line}" > "${profile}"
  fi
}
