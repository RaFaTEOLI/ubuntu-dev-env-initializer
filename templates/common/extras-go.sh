#!/usr/bin/env bash
# Purpose: Install Go from upstream tarball into /usr/local (or override prefix).
#
# Env:
#   GO_VERSION — e.g. 1.22.1 (default fetched from latest stable via redirect)
#
# Templating: {{GO_VERSION}}

ldw_extra_install_go() {
  if ldw_command_exists go; then
    ldw_log "go already installed: $(go version)"
    return 0
  fi

  ldw_apt_install curl tar

  : "${GO_VERSION:=1.22.1}"
  local arch="linux-amd64"
  case "$(uname -m)" in
    aarch64|arm64) arch="linux-arm64" ;;
    x86_64) arch="linux-amd64" ;;
    *) ldw_die "Unsupported architecture for Go bootstrap" ;;
  esac

  local ver="${GO_VERSION}"
  local url="https://go.dev/dl/go${ver}.${arch}.tar.gz"
  ldw_log "Downloading ${url}"
  curl -fsSL "${url}" -o /tmp/go.tgz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tgz
  rm -f /tmp/go.tgz

  local marker="# Go (Linux Dev Wizard)"
  local line='export PATH=$PATH:/usr/local/go/bin'
  grep -qF "${marker}" "${LDW_HOME}/.profile" 2>/dev/null || {
    printf '\n%s\n%s\n' "${marker}" "${line}" >> "${LDW_HOME}/.profile"
  }

  ldw_log "Go ${ver} installed to /usr/local/go"
}
