#!/usr/bin/env bash
# Purpose: Install 1Password CLI (op) from 1Password’s APT repository.
#
# Templating: {{ONEPASSWORD_CHANNEL}} (stable|beta)

ldw_extra_install_1password_cli() {
  if ldw_command_exists op; then
    ldw_log "1Password CLI already installed"
    return 0
  fi
  if ! ldw_have_apt; then
    ldw_warn "apt required for 1Password CLI repository install."
    return 1
  fi
  ldw_log "Adding 1Password APT repository"
  curl -sS https://downloads.1password.com/linux/keys/1password.asc \
    | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" \
    | sudo tee /etc/apt/sources.list.d/1password.list >/dev/null
  ldw_apt_update
  ldw_apt_install 1password-cli
}
