#!/usr/bin/env bash
# Purpose: Install Hyper terminal from the official .deb release (fallback last choice).
#          Optionally copy a Hyper config via HYPER_CONFIG_FROM → ~/.hyper.js.
#
# Env:
#   HYPER_CONFIG_FROM — if set and readable, copied to \${LDW_HOME}/.hyper.js after install
#
# Templating: {{INSTALL_TERMINAL}} (=hyper)

ldw_terminal_install_hyper() {
  if ! ldw_command_exists hyper; then
    if ! ldw_have_apt; then
      ldw_warn "apt/dpkg not available; skipping Hyper .deb install."
      return 1
    fi
    ldw_apt_install wget
    local deb="/tmp/hyper.deb"
    wget -qO "${deb}" "https://releases.hyper.is/download/deb" || {
      ldw_warn "Hyper download failed."
      return 1
    }
    sudo dpkg -i "${deb}" || sudo apt-get -f install -y
    rm -f "${deb}"
    ldw_log "Hyper installed"
  else
    ldw_log "hyper already installed"
  fi

  # Apply even when Hyper was already present (e.g. install first, config second).
  if [[ -n "${HYPER_CONFIG_FROM:-}" ]] && [[ -r "${HYPER_CONFIG_FROM}" ]]; then
    cp -f "${HYPER_CONFIG_FROM}" "${LDW_HOME}/.hyper.js"
    chmod 644 "${LDW_HOME}/.hyper.js" 2>/dev/null || true
    ldw_log "Installed Hyper config from ${HYPER_CONFIG_FROM}"
  fi
}
