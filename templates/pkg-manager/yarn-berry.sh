#!/usr/bin/env bash
# Purpose: Enable Yarn Berry (modern Yarn) via Corepack after Node is available.
#
# Templating: {{YARN_VERSION}}, {{PACKAGE_MANAGER}} (=yarn)

ldw_pkg_install_yarn_berry() {
  if ! ldw_command_exists corepack && ! ldw_command_exists npm; then
    ldw_warn "Install Node first (INSTALL_RUNTIME=node or bun) so Corepack/npm is available."
    return 1
  fi

  if ldw_command_exists corepack; then
    sudo corepack enable || true
    if [[ -n "${YARN_VERSION:-}" ]]; then
      sudo corepack prepare "yarn@${YARN_VERSION}" --activate
    else
      sudo corepack prepare yarn@stable --activate
    fi
  elif ldw_command_exists npm; then
    sudo npm install -g yarn
  fi

  ldw_log "Yarn: $(yarn --version 2>/dev/null || echo 'pending new shell')"
}
