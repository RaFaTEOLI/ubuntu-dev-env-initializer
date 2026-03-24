#!/usr/bin/env bash
# Purpose: Install Postman REST client (Linux x64 tarball from Postman CDN).
#
# Env:
#   POSTMAN_TARBALL_URL — override download URL (default: official latest64_linux)
#
# Templating: {{POSTMAN_VERSION}}

ldw_extra_install_postman() {
  if ldw_command_exists postman; then
    ldw_log "Postman already on PATH: $(command -v postman)"
    return 0
  fi

  local arch
  arch="$(uname -m)"
  case "${arch}" in
    x86_64) ;;
    *) ldw_warn "Postman tarball path is only wired for x86_64; arch=${arch}"; return 1 ;;
  esac

  ldw_require_sudo
  ldw_apt_install curl tar

  : "${POSTMAN_TARBALL_URL:=https://dl.pstmn.io/download/latest64_linux}"
  local tmp="/tmp/postman-linux-x64.tar.gz"
  ldw_log "Downloading Postman"
  curl -fsSL "${POSTMAN_TARBALL_URL}" -o "${tmp}"

  sudo rm -rf /opt/Postman
  sudo tar -xzf "${tmp}" -C /opt
  rm -f "${tmp}"

  local exe="/opt/Postman/Postman"
  if [[ ! -x "${exe}" ]]; then
    exe="$(sudo find /opt -maxdepth 5 \( -iname 'Postman' -o -iname 'postman' \) -type f -executable 2>/dev/null | head -1 || true)"
  fi
  if [[ -z "${exe}" || ! -x "${exe}" ]]; then
    ldw_warn "Could not locate Postman binary under /opt after extract."
    return 1
  fi
  sudo ln -sf "${exe}" /usr/local/bin/postman

  ldw_log "Postman installed: try \`postman\` (${exe})"
}
