#!/usr/bin/env bash
# Purpose: Install Cursor editor (.deb); URL/version overridable via env (see below).
#
# Env:
#   CURSOR_DEB_URL — full .deb URL (overrides version-based default)
#   CURSOR_VERSION — e.g. 2.6 (used when CURSOR_DEB_URL unset); default: latest
#
# Templating: {{CURSOR_DEB_URL}}, {{CURSOR_VERSION}}

ldw_editor_install_cursor() {
  if ldw_command_exists cursor; then
    ldw_log "Cursor appears already installed"
    return 0
  fi
  if ! ldw_have_apt; then
    ldw_warn "apt/dpkg required for Cursor .deb install."
    return 1
  fi

  ldw_apt_install wget ca-certificates

  local deb="/tmp/cursor.deb"
  local url="${CURSOR_DEB_URL:-}"

  if [[ -z "${url}" ]]; then
    : "${CURSOR_VERSION:=latest}"
    local arch_path="linux-x64-deb"
    case "$(uname -m)" in
      aarch64|arm64) arch_path="linux-arm64-deb" ;;
      x86_64) arch_path="linux-x64-deb" ;;
      *) ldw_warn "Unsupported arch for Cursor deb"; return 1 ;;
    esac
    url="https://api2.cursor.sh/updates/download/golden/${arch_path}/cursor/${CURSOR_VERSION}"
  fi

  ldw_log "Downloading Cursor: ${url}"
  wget -qO "${deb}" "${url}" || curl -fsSL "${url}" -o "${deb}"

  sudo dpkg -i "${deb}" || sudo apt-get -f install -y
  rm -f "${deb}"
  ldw_log "Cursor installed"
}
