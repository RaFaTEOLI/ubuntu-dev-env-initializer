#!/usr/bin/env bash
# Purpose: Install a desktop web browser via APT repositories or distro packages.
#          Used by INSTALL_EXTRAS tokens: chrome, edge, firefox, chromium, or browser (+ INSTALL_BROWSER).
#
# Env:
#   INSTALL_BROWSER — chrome | edge | firefox | chromium (when extra token is \`browser\` only)
#
# Templating: {{INSTALL_BROWSER}}

ldw_extra_install_browser_google_chrome() {
  if dpkg -l google-chrome-stable >/dev/null 2>&1 || ldw_command_exists google-chrome-stable; then
    ldw_log "Google Chrome already installed"
    return 0
  fi
  if ! ldw_have_apt; then
    ldw_warn "apt required for Chrome repository install."
    return 1
  fi

  ldw_require_sudo
  ldw_apt_install wget gnupg

  wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg

  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null

  ldw_apt_update
  ldw_apt_install google-chrome-stable
  ldw_log "Google Chrome installed"
}

ldw_extra_install_browser_microsoft_edge() {
  if ldw_command_exists microsoft-edge-stable || ldw_command_exists edge; then
    ldw_log "Microsoft Edge already present"
    return 0
  fi
  if ! ldw_have_apt; then
    ldw_warn "apt required for Edge repository install."
    return 1
  fi

  ldw_require_sudo
  ldw_apt_install wget gnupg

  wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg >/dev/null

  local distro_id
  distro_id="$(. /etc/os-release && echo "${ID:-}")"
  if [[ "${distro_id}" == "debian" ]]; then
    echo "deb [signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" \
      | sudo tee /etc/apt/sources.list.d/microsoft-edge.list >/dev/null
  else
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" \
      | sudo tee /etc/apt/sources.list.d/microsoft-edge.list >/dev/null
  fi

  ldw_apt_update
  ldw_apt_install microsoft-edge-stable
  ldw_log "Microsoft Edge installed"
}

ldw_extra_install_browser_firefox() {
  if ldw_command_exists firefox; then
    ldw_log "Firefox already installed"
    return 0
  fi
  if ! ldw_have_apt; then
    ldw_warn "apt required."
    return 1
  fi
  ldw_apt_install firefox
  ldw_log "Firefox installed"
}

ldw_extra_install_browser_chromium() {
  if ldw_command_exists chromium || ldw_command_exists chromium-browser; then
    ldw_log "Chromium already installed"
    return 0
  fi
  if ! ldw_have_apt; then
    ldw_warn "apt required."
    return 1
  fi
  ldw_apt_install chromium-browser 2>/dev/null || ldw_apt_install chromium
  ldw_log "Chromium installed"
}

# When INSTALL_EXTRAS contains \`browser\`, dispatch by INSTALL_BROWSER (default: chrome).
ldw_extra_install_browser_dispatch() {
  : "${INSTALL_BROWSER:=chrome}"
  case "${INSTALL_BROWSER}" in
    chrome) ldw_extra_install_browser_google_chrome ;;
    edge) ldw_extra_install_browser_microsoft_edge ;;
    firefox) ldw_extra_install_browser_firefox ;;
    chromium) ldw_extra_install_browser_chromium ;;
    *)
      ldw_warn "Unknown INSTALL_BROWSER='${INSTALL_BROWSER}' (use chrome|edge|firefox|chromium)"
      return 1
      ;;
  esac
}
