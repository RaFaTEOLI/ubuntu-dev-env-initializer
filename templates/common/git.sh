#!/usr/bin/env bash
# Purpose: Git + Git LFS + optional GitHub CLI + optional SSH key setup for Git remotes (GitHub-ready).
#          Non-interactive, env-driven install (see GIT_* and GIT_SSH_* variables).
#
# Requires: templates/base.sh sourced first (provides ldw_log, ldw_apt_install, LDW_HOME, …).
#
# Env — identity & extras:
#   GIT_USER_NAME        — git config user.name
#   GIT_USER_EMAIL       — git config user.email
#   GITCONFIG            — extra lines appended to ~/.gitconfig (multiline safe)
#   GIT_INSTALL_GH=yes   — install GitHub CLI (gh) from official APT repo
#
# Env — SSH (when GIT_SSH_SETUP=yes):
#   GIT_SSH_SETUP=yes          — generate Ed25519 key, ssh-agent add, GitHub Host block, show pubkey
#   GIT_SSH_KEY_PATH           — private key path (default: ${LDW_HOME}/.ssh/id_ed25519)
#   GIT_SSH_KEY_COMMENT        — ssh-keygen -C (default: GIT_USER_EMAIL or user@host)
#   GIT_SSH_INTERACTIVE=yes    — interactive passphrase prompt (TTY); for manual runs only
#   GIT_SSH_SKIP_PASSPHRASE=yes — empty passphrase (automation / generated scripts)
#   GIT_SSH_GH_KEY_TITLE        — if set and \`gh\` is authenticated, \`gh ssh-key add\` with this title
#
# Templating: {{GIT_USER_NAME}}, {{GIT_USER_EMAIL}}, {{GIT_SSH_KEY_COMMENT}}

# --- internal: SSH dir + GitHub ssh config ---------------------------------

_ldw_git_ensure_ssh_dir() {
  local ssh_dir="${LDW_HOME}/.ssh"
  mkdir -p "${ssh_dir}"
  chmod 700 "${ssh_dir}"
}

_ldw_git_write_github_ssh_config() {
  local key_path="$1"
  local marker="# linux-dev-wizard: github.com"
  local config="${LDW_HOME}/.ssh/config"
  _ldw_git_ensure_ssh_dir
  if [[ -f "${config}" ]] && grep -qF "${marker}" "${config}" 2>/dev/null; then
    return 0
  fi
  {
    echo ""
    echo "${marker}"
    echo "Host github.com"
    echo "  HostName github.com"
    echo "  User git"
    echo "  IdentityFile ${key_path}"
    echo "  IdentitiesOnly yes"
  } >> "${config}"
  chmod 600 "${config}"
}

# Public: SSH key + agent + GitHub config + optional gh upload (callable on its own).
ldw_git_setup_ssh() {
  if ! ldw_command_exists ssh-keygen; then
    if ldw_have_apt; then
      ldw_apt_install openssh-client
    else
      ldw_warn "ssh-keygen not found; install openssh-client first."
      return 1
    fi
  fi

  local priv="${GIT_SSH_KEY_PATH:-${LDW_HOME}/.ssh/id_ed25519}"
  local pub="${priv}.pub"
  local comment="${GIT_SSH_KEY_COMMENT:-}"
  comment="${comment:-${GIT_USER_EMAIL:-}}"
  comment="${comment:-${USER:-user}@$(hostname)}"

  _ldw_git_ensure_ssh_dir

  if [[ -f "${priv}" ]]; then
    ldw_log "SSH private key already exists at ${priv} — skipping ssh-keygen"
  else
    ldw_log "Generating Ed25519 SSH key at ${priv}"
    if [[ "${GIT_SSH_INTERACTIVE:-}" == "yes" ]] && [[ -t 0 ]]; then
      ldw_log "Interactive mode: you will be prompted for an optional passphrase"
      ssh-keygen -t ed25519 -C "${comment}" -f "${priv}"
    elif [[ "${GIT_SSH_SKIP_PASSPHRASE:-}" == "yes" ]]; then
      ssh-keygen -t ed25519 -C "${comment}" -f "${priv}" -N ""
    else
      ldw_warn "Unattended key generation: using empty passphrase (set GIT_SSH_SKIP_PASSPHRASE=yes to silence, or GIT_SSH_INTERACTIVE=yes for a TTY prompt)"
      ssh-keygen -t ed25519 -C "${comment}" -f "${priv}" -N ""
    fi
  fi

  chmod 600 "${priv}" 2>/dev/null || true
  chmod 644 "${pub}" 2>/dev/null || true

  if [[ -f "${priv}" ]]; then
    eval "$(ssh-agent -s)" >/dev/null
    ssh-add "${priv}" 2>/dev/null || true
    _ldw_git_write_github_ssh_config "${priv}"
  fi

  ldw_log "Tip: new shells may need: ssh-add ${priv} (unless your desktop integrates ssh-agent)"
  ldw_log "Public key (add to GitHub → Settings → SSH keys, or other Git hosts):"
  cat "${pub}" 2>/dev/null || true

  if [[ -n "${GIT_SSH_GH_KEY_TITLE:-}" ]] && ldw_command_exists gh; then
    if gh auth status >/dev/null 2>&1; then
      if gh ssh-key add "${pub}" --title "${GIT_SSH_GH_KEY_TITLE}"; then
        ldw_log "Uploaded SSH public key to GitHub via gh (${GIT_SSH_GH_KEY_TITLE})"
      fi
    else
      ldw_warn "gh is not authenticated; run 'gh auth login' then re-run or add the key above manually."
    fi
  elif [[ -n "${GIT_SSH_GH_KEY_TITLE:-}" ]]; then
    ldw_warn "GIT_SSH_GH_KEY_TITLE set but gh not installed or not in PATH."
  fi
}

# --- main install -----------------------------------------------------------

ldw_common_install_git() {
  if ldw_have_apt; then
    # openssh-client: ssh-keygen / ssh for Git over SSH (also used when SSH setup runs after identity-only install)
    ldw_apt_install git git-lfs openssh-client
  else
    ldw_warn "apt not found; skipping git apt install."
  fi

  if ldw_command_exists git; then
    git lfs install 2>/dev/null || true
  fi

  if ldw_command_exists git; then
    git config --global init.defaultBranch main 2>/dev/null || true
    git config --global pull.rebase false 2>/dev/null || true
    git config --global fetch.prune true 2>/dev/null || true
  fi

  if ldw_command_exists git && [[ -n "${GIT_USER_NAME:-}" ]]; then
    git config --global user.name "${GIT_USER_NAME}" || true
  fi
  if ldw_command_exists git && [[ -n "${GIT_USER_EMAIL:-}" ]]; then
    git config --global user.email "${GIT_USER_EMAIL}" || true
  fi

  if [[ -n "${GITCONFIG:-}" ]]; then
    printf '%s\n' "${GITCONFIG}" >> "${LDW_HOME}/.gitconfig"
  fi

  if [[ "${GIT_INSTALL_GH:-}" == "yes" ]] && ldw_have_apt && ! ldw_command_exists gh; then
    ldw_log "Installing GitHub CLI (gh)"
    ldw_apt_install wget
    sudo install -d -m0755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    ldw_apt_update
    ldw_apt_install gh
  fi

  if [[ "${GIT_SSH_SETUP:-}" == "yes" ]]; then
    ldw_git_setup_ssh
  fi

  ldw_log "git ready: $(git --version 2>/dev/null || echo 'missing') $(git lfs version 2>/dev/null | head -1 || true)"
}
