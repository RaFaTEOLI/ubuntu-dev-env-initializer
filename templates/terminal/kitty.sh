#!/usr/bin/env bash
# Purpose: Install Kitty terminal via official installer script (works on many distros).
#
# Templating: {{INSTALL_TERMINAL}} (=kitty)

ldw_terminal_install_kitty() {
  if ldw_command_exists kitty; then
    ldw_log "kitty already installed"
    return 0
  fi
  ldw_log "Installing Kitty"
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
  ldw_log "Kitty installer finished (see script output for desktop integration)."
}
