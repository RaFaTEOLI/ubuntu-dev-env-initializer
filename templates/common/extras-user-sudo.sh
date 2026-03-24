#!/usr/bin/env bash
# Purpose: Ensure the real user (SUDO_USER or current user) is in the \`sudo\` group.
#          Idempotent: no-op if the user is already in the sudo group.
#
# Templating: {{LDW_TARGET_USER}}

ldw_extra_user_add_to_sudo_group() {
  ldw_require_sudo

  local target="${LDW_TARGET_USER:-${SUDO_USER:-}}"
  if [[ -z "${target}" ]]; then
    target="$(id -un)"
  fi

  if groups "${target}" 2>/dev/null | grep -qw sudo; then
    ldw_log "User ${target} is already in the sudo group"
    return 0
  fi

  ldw_log "Adding user ${target} to the sudo group"
  sudo usermod -aG sudo "${target}"
  ldw_warn "Log out and back in (or reboot) for group membership to apply in all sessions."
}
