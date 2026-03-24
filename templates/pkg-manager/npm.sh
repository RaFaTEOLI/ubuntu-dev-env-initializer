#!/usr/bin/env bash
# Purpose: Ensure npm is available (ships with Node or via nvm); no separate install on Debian.
#
# Templating: {{PACKAGE_MANAGER}} (=npm)

ldw_pkg_ensure_npm() {
  if ldw_command_exists npm; then
    ldw_log "npm present: $(npm --version)"
    return 0
  fi
  ldw_warn "npm missing; install Node (INSTALL_RUNTIME=node) or bun which provides a compatible toolchain."
  return 1
}
