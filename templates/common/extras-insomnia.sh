#!/usr/bin/env bash
# Purpose: Install Insomnia API client (.deb from Kong GitHub releases).
#
# Env:
#   INSOMNIA_DEB_URL — full URL to a specific .deb (skips GitHub resolution)
#
# Templating: {{INSOMNIA_DEB_URL}}

ldw_extra_install_insomnia() {
  if ldw_command_exists insomnia; then
    ldw_log "Insomnia already installed"
    return 0
  fi

  if ! ldw_have_apt; then
    ldw_warn "apt/dpkg required for Insomnia .deb install."
    return 1
  fi

  ldw_apt_install curl ca-certificates

  local deb_url="${INSOMNIA_DEB_URL:-}"
  if [[ -z "${deb_url}" ]]; then
    ldw_log "Resolving latest Insomnia .deb from GitHub API"
    # Pick first .deb asset URL from the latest release (no jq dependency).
    deb_url="$(
      curl -fsSL https://api.github.com/repos/Kong/insomnia/releases/latest \
        | grep -oE 'https://[^"]+\.deb' | grep -i 'insomnia' | head -1 || true
    )"
  fi

  if [[ -z "${deb_url}" ]]; then
    ldw_warn "Could not resolve Insomnia .deb URL; set INSOMNIA_DEB_URL manually."
    return 1
  fi

  local deb="/tmp/insomnia.deb"
  ldw_log "Downloading ${deb_url}"
  curl -fsSL "${deb_url}" -o "${deb}"
  sudo dpkg -i "${deb}" || sudo apt-get -f install -y
  rm -f "${deb}"

  ldw_log "Insomnia installed"
}
