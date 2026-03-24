#!/usr/bin/env bash
# Purpose: Install the Starship cross-shell prompt and append init lines to rc files
#          based on INSTALL_SHELL (exported by main.sh).
#
# Env:
#   STARSHIP_BIN — override install path (default: ~/.local/bin/starship)
#
# Templating: {{STARSHIP_VERSION}}

ldw_common_install_starship() {
  export PATH="${LDW_HOME}/.local/bin:${PATH}"
  if ldw_command_exists starship; then
    ldw_log "starship already installed: $(command -v starship)"
  else
    ldw_log "Installing Starship prompt"
    local bin_dir="${LDW_HOME}/.local/bin"
    mkdir -p "${bin_dir}"
    if ! curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "${bin_dir}"; then
      ldw_warn "Starship install script failed."
      return 1
    fi
  fi

  local marker="# starship (Linux Dev Wizard)"
  local init_line='eval "$(starship init bash)"'

  _ldw_append_line() {
    local file="$1"
    local line="$2"
    [[ -f "${file}" ]] || touch "${file}"
    if grep -qF "${marker}" "${file}" 2>/dev/null; then
      return 0
    fi
    printf '\n%s\n%s\n' "${marker}" "${line}" >> "${file}"
  }

  case "${INSTALL_SHELL:-}" in
    zsh)
      _ldw_append_line "${LDW_HOME}/.zshrc" 'eval "$(starship init zsh)"'
      ;;
    fish)
      _ldw_append_line "${LDW_HOME}/.config/fish/config.fish" 'starship init fish | source'
      mkdir -p "${LDW_HOME}/.config/fish"
      ;;
    bash|"")
      _ldw_append_line "${LDW_HOME}/.bashrc" "${init_line}"
      ;;
  esac

  ldw_log "Starship configured for INSTALL_SHELL=${INSTALL_SHELL:-bash}"
}
