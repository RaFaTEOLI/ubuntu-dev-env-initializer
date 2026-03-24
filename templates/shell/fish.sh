#!/usr/bin/env bash
# Purpose: Install Fish shell from official PPA (Ubuntu) or Debian repos; optional default shell.
#
# Env: SET_DEFAULT_SHELL=yes|no (default: yes)
#
# Templating: {{INSTALL_SHELL}} (=fish)

ldw_shell_install_fish() {
  if ldw_command_exists fish; then
    ldw_log "fish already installed: $(command -v fish)"
  else
    if ldw_have_apt; then
      # Ubuntu: Fish 3+ PPA; Debian bookworm+: fish is in main
      if grep -qi ubuntu /etc/os-release 2>/dev/null; then
        ldw_apt_install software-properties-common
        sudo add-apt-repository -y ppa:fish-shell/release-3
        ldw_apt_update
      fi
      ldw_apt_install fish
    else
      ldw_die "apt not found; cannot install fish."
    fi
  fi

  local fish_path
  fish_path="$(command -v fish)"
  : "${SET_DEFAULT_SHELL:=yes}"
  if [[ "${SET_DEFAULT_SHELL}" == "yes" ]] && [[ -n "${SUDO_USER:-}" ]]; then
    sudo chsh -s "${fish_path}" "${SUDO_USER}"
  elif [[ "${SET_DEFAULT_SHELL}" == "yes" ]]; then
    chsh -s "${fish_path}" || ldw_warn "chsh failed; set default shell manually."
  fi

  ldw_log "Fish installation complete"
}
