#!/usr/bin/env bash
# Purpose: Install WezTerm from the official Fury APT repository (Debian/Ubuntu).
#
# Templating: {{INSTALL_TERMINAL}} (=wezterm)

ldw_terminal_install_wezterm() {
  if ldw_command_exists wezterm; then
    ldw_log "wezterm already installed: $(command -v wezterm)"
    return 0
  fi

  if ! ldw_have_apt; then
    ldw_warn "apt not found; cannot install WezTerm via repository."
    return 1
  fi

  ldw_require_sudo
  ldw_log "Adding WezTerm APT repository"

  sudo install -d -m0755 /usr/share/keyrings
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg

  echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" \
    | sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null

  ldw_apt_update
  ldw_apt_install wezterm

  ldw_log "WezTerm installation complete"
}
