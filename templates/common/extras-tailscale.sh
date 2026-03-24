#!/usr/bin/env bash
# Purpose: Install Tailscale using the official Linux install script.
#
# Templating: {{TAILSCALE_VERSION}}

ldw_extra_install_tailscale() {
  if ldw_command_exists tailscale; then
    ldw_log "tailscale already installed"
    return 0
  fi
  ldw_log "Installing Tailscale"
  curl -fsSL https://tailscale.com/install.sh | sh
}
