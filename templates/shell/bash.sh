#!/usr/bin/env bash
# Purpose: Minimal bash improvements: history, globbing, and a marker block in ~/.bashrc.
#
# Templating: {{INSTALL_SHELL}} (=bash)

ldw_shell_install_bash_enhancements() {
  local rc="${LDW_HOME}/.bashrc"
  local marker="# Linux Dev Wizard bash defaults"
  touch "${rc}"

  if grep -qF "${marker}" "${rc}" 2>/dev/null; then
    ldw_log "Bash enhancements already present; skipping"
    return 0
  fi

  ldw_log "Appending bash quality-of-life settings to ${rc}"
  cat >> "${rc}" <<'EOF'

# Linux Dev Wizard bash defaults
shopt -s histappend
export HISTCONTROL=ignoreboth
export HISTSIZE=50000
export HISTFILESIZE=50000
shopt -s globstar 2>/dev/null || true
EOF

  ldw_log "Bash enhancements applied"
}
