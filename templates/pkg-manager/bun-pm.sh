#!/usr/bin/env bash
# Purpose: Document that Bun is both runtime and package manager; ensure bun install exists.
#
# Templating: {{PACKAGE_MANAGER}} (=bun)

ldw_pkg_use_bun_as_pm() {
  if ! ldw_command_exists bun; then
    ldw_warn "bun not found; install INSTALL_RUNTIME=bun first."
    return 1
  fi
  ldw_log "Using bun as package manager: $(bun --version)"
}
