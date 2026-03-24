#!/usr/bin/env bash
# Purpose: Install Neovim from APT and clone LazyVim starter if config absent.
#
# Templating: {{INSTALL_EDITOR}} (=neovim)

ldw_editor_install_neovim_lazy() {
  if ldw_have_apt; then
    ldw_apt_install neovim git || ldw_warn "neovim package unavailable; try appimage or build from source."
  fi

  local cfg="${LDW_HOME}/.config/nvim"
  if [[ ! -f "${cfg}/init.lua" ]]; then
    ldw_log "Cloning LazyVim starter template"
    git clone https://github.com/LazyVim/starter "${cfg}" || true
    rm -rf "${cfg}/.git"
  else
    ldw_log "Neovim config already exists; skipping LazyVim clone"
  fi
}
