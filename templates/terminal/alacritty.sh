#!/usr/bin/env bash
# Purpose: Install Alacritty from Debian/Ubuntu repositories when available.
#
# Templating: {{INSTALL_TERMINAL}} (=alacritty)

ldw_terminal_install_alacritty() {
  if ldw_command_exists alacritty; then
    ldw_log "alacritty already installed"
    return 0
  fi
  if ldw_have_apt; then
    ldw_apt_install alacritty || ldw_warn "alacritty package missing on this release; install from source or backports."
  else
    ldw_warn "apt not found; cannot install alacritty."
  fi
}
