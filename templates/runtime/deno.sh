#!/usr/bin/env bash
# Purpose: Install Deno (https://deno.land) if missing.
#
# Templating: {{DENO_VERSION}}

ldw_runtime_install_deno() {
  if ldw_command_exists deno; then
    ldw_log "deno already installed: $(deno --version)"
    return 0
  fi
  ldw_log "Installing Deno"
  curl -fsSL https://deno.land/install.sh | sh
  local deno_bin="${LDW_HOME}/.deno/bin"
  export PATH="${deno_bin}:${PATH}"
  if [[ -d "${deno_bin}" ]]; then
    grep -q '.deno/bin' "${LDW_HOME}/.profile" 2>/dev/null || echo "export PATH=\"\$HOME/.deno/bin:\$PATH\"" >> "${LDW_HOME}/.profile"
  fi
  ldw_log "Deno installed"
}
