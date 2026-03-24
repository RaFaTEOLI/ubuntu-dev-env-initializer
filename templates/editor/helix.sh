#!/usr/bin/env bash
# Purpose: Install Helix editor from distro packages when available.
#
# Templating: {{INSTALL_EDITOR}} (=helix)

ldw_editor_install_helix() {
  if ldw_command_exists hx; then
    ldw_log "Helix already installed"
    return 0
  fi
  if ldw_have_apt; then
    ldw_apt_install helix || ldw_warn "helix not in default repos; see https://docs.helix-editor.com/install.html"
  fi
}
