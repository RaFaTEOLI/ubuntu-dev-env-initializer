#!/usr/bin/env bash
# Purpose: Install Rust toolchain via rustup (non-interactive, default profile).
#
# Templating: {{RUST_DEFAULT_TOOLCHAIN}}

ldw_extra_install_rustup() {
  if ldw_command_exists rustc; then
    ldw_log "Rust already present: $(rustc --version)"
    return 0
  fi
  ldw_log "Installing rustup"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  ldw_log "rustup installed; run: source \"${LDW_HOME}/.cargo/env\""
}
