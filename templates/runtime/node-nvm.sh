#!/usr/bin/env bash
# Purpose: Install nvm and a default Node.js LTS release (idempotent nvm install).
#
# Env:
#   NVM_VERSION — nvm git tag (default: v0.40.1)
#   NODE_VERSION — Node version for nvm install (default: --lts)
#
# Templating: {{NVM_VERSION}}, {{NODE_VERSION}}

ldw_runtime_install_node_nvm() {
  local nvm_dir="${NVM_DIR:-${LDW_HOME}/.nvm}"
  export NVM_DIR="${nvm_dir}"

  if [[ ! -d "${NVM_DIR}" ]]; then
    ldw_log "Installing nvm"
    : "${NVM_VERSION:=v0.40.1}"
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
  else
    ldw_log "nvm already present at ${NVM_DIR}"
  fi

  # shellcheck disable=SC1090
  [[ -s "${NVM_DIR}/nvm.sh" ]] && . "${NVM_DIR}/nvm.sh"

  : "${NODE_VERSION:=lts}"
  ldw_log "Installing Node via nvm (NODE_VERSION=${NODE_VERSION})"
  if [[ "${NODE_VERSION}" == "lts" || "${NODE_VERSION}" == "lts/*" ]]; then
    nvm install --lts
    nvm alias default 'lts/*'
  else
    nvm install "${NODE_VERSION}"
    nvm alias default "${NODE_VERSION}"
  fi

  ldw_log "Node active: $(node --version 2>/dev/null || echo 'open a new shell')"
}
