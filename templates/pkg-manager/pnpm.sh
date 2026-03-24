#!/usr/bin/env bash
# Purpose: Enable pnpm via Corepack (Node 16.13+) or global npm install fallback.
#
# Env:
#   PNPM_VERSION — optional exact version for corepack prepare (e.g. 9.15.0)
#
# Templating: {{PNPM_VERSION}}, {{PACKAGE_MANAGER}} (=pnpm)

ldw_pkg_install_pnpm() {
  ldw_log "Installing / enabling pnpm"

  if ldw_command_exists pnpm; then
    ldw_log "pnpm already installed: $(pnpm --version)"
    return 0
  fi

  # Prefer Corepack when Node is available
  if ldw_command_exists corepack; then
    ldw_log "Using corepack to enable pnpm"
    sudo corepack enable || true
    if [[ -n "${PNPM_VERSION:-}" ]]; then
      sudo corepack prepare "pnpm@${PNPM_VERSION}" --activate
    else
      sudo corepack prepare pnpm@latest --activate
    fi
    return 0
  fi

  # Fallback: npm global (requires npm) — prefer user install when npm is user-local (nvm)
  if ldw_command_exists npm; then
    ldw_log "Installing pnpm globally via npm"
    if npm install -g pnpm 2>/dev/null; then
      return 0
    fi
    sudo npm install -g pnpm
    return 0
  fi

  # Last resort: standalone script
  if ldw_command_exists curl; then
    ldw_log "Installing pnpm via standalone script"
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    return 0
  fi

  ldw_warn "Could not install pnpm: install Node/npm or Corepack first."
}
