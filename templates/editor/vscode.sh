#!/usr/bin/env bash
# Purpose: Install Visual Studio Code from Microsoft’s APT repository and common extensions.
#
# Env:
#   VSCODE_EXTENSIONS — space-separated extension ids (optional override)
#
# Templating: {{VSCODE_EXTENSIONS}}

ldw_editor_install_vscode() {
  if ldw_command_exists code; then
    ldw_log "VS Code already installed"
  else
    if ! ldw_have_apt; then
      ldw_die "apt required for VS Code .deb repo install"
    fi
    ldw_apt_install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/ms-vscode.gpg >/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ms-vscode.gpg] https://packages.microsoft.com/repos/code stable main" \
      | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    ldw_apt_update
    ldw_apt_install code
  fi

  : "${VSCODE_EXTENSIONS:=eamodio.gitlens dbaeumer.vscode-eslint esbenp.prettier-vscode ms-azuretools.vscode-docker}"

  if ldw_command_exists code; then
    local ext
    for ext in ${VSCODE_EXTENSIONS}; do
      code --install-extension "${ext}" --force || true
    done
  fi

  ldw_log "VS Code setup complete"
}
