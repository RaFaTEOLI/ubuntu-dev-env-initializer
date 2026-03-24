#!/usr/bin/env bash
# Purpose: Linux Dev Wizard — entry point. Sources base.sh, then conditionally sources
#          shell / terminal / runtime / package manager / editor / extras from env vars.
#
# Module layout (all under templates/): base.sh, shell/*, terminal/*, runtime/*,
# pkg-manager/*, editor/*, common/* — driven by INSTALL_* env vars (see below).
#
# Configuration: set environment variables before running, e.g.:
#   INSTALL_SHELL=zsh INSTALL_TERMINAL=wezterm INSTALL_RUNTIME=bun \
#   INSTALL_PKG_MANAGER=pnpm INSTALL_EDITOR=vscode \
#   INSTALL_EXTRAS=docker,starship,nerd-fonts,postman,insomnia,chrome,git ./main.sh
#
# Browsers: use extras chrome | edge | firefox | chromium, or \`browser\` with INSTALL_BROWSER=chrome|...
#
# Templating placeholders for generated bundles: {{INSTALL_SHELL}}, {{INSTALL_TERMINAL}},
# {{INSTALL_RUNTIME}}, {{INSTALL_PKG_MANAGER}}, {{INSTALL_EDITOR}}, {{INSTALL_EXTRAS}}

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LDW_TEMPLATE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=base.sh
source "${SCRIPT_DIR}/base.sh"

# Defaults are empty = skip optional sections (no hidden installs).
: "${INSTALL_SHELL:=}"
: "${INSTALL_TERMINAL:=}"
: "${INSTALL_RUNTIME:=}"
: "${INSTALL_PKG_MANAGER:=}"
: "${INSTALL_EDITOR:=}"
: "${INSTALL_EXTRAS:=}"
: "${INSTALL_BROWSER:=chrome}"

export INSTALL_SHELL INSTALL_TERMINAL INSTALL_RUNTIME INSTALL_PKG_MANAGER INSTALL_EDITOR INSTALL_EXTRAS INSTALL_BROWSER

ldw_log "Linux Dev Wizard — starting"
ldw_log "Choices: shell=${INSTALL_SHELL:-∅} terminal=${INSTALL_TERMINAL:-∅} runtime=${INSTALL_RUNTIME:-∅} pkg=${INSTALL_PKG_MANAGER:-∅} editor=${INSTALL_EDITOR:-∅} extras=${INSTALL_EXTRAS:-∅} browser=${INSTALL_BROWSER:-∅}"

ldw_require_sudo

# --- Core bootstrap: curl + ca certs (needed by many installers) ---
if ldw_have_apt; then
  ldw_apt_install ca-certificates curl gnupg lsb-release
fi

# --- Shell ---
case "${INSTALL_SHELL}" in
  zsh)
    # shellcheck source=shell/zsh.sh
    source "${SCRIPT_DIR}/shell/zsh.sh"
    ldw_shell_install_zsh
    ;;
  fish)
    # shellcheck source=shell/fish.sh
    source "${SCRIPT_DIR}/shell/fish.sh"
    ldw_shell_install_fish
    ;;
  bash)
    # shellcheck source=shell/bash.sh
    source "${SCRIPT_DIR}/shell/bash.sh"
    ldw_shell_install_bash_enhancements
    ;;
  ""|none)
    ldw_log "Skipping shell setup (INSTALL_SHELL empty or none)."
    ;;
  *)
    ldw_warn "Unknown INSTALL_SHELL={{INSTALL_SHELL}} value '${INSTALL_SHELL}'; skipping."
    ;;
esac

# --- Terminal emulator ---
case "${INSTALL_TERMINAL}" in
  wezterm)
    # shellcheck source=terminal/wezterm.sh
    source "${SCRIPT_DIR}/terminal/wezterm.sh"
    ldw_terminal_install_wezterm
    ;;
  kitty)
    # shellcheck source=terminal/kitty.sh
    source "${SCRIPT_DIR}/terminal/kitty.sh"
    ldw_terminal_install_kitty
    ;;
  alacritty)
    # shellcheck source=terminal/alacritty.sh
    source "${SCRIPT_DIR}/terminal/alacritty.sh"
    ldw_terminal_install_alacritty
    ;;
  hyper)
    # shellcheck source=terminal/hyper.sh
    source "${SCRIPT_DIR}/terminal/hyper.sh"
    ldw_terminal_install_hyper
    ;;
  ""|none)
    ldw_log "Skipping terminal (INSTALL_TERMINAL empty or none)."
    ;;
  *)
    ldw_warn "Unknown INSTALL_TERMINAL value '${INSTALL_TERMINAL}'; skipping."
    ;;
esac

# --- JS/TS runtimes ---
case "${INSTALL_RUNTIME}" in
  bun)
    # shellcheck source=runtime/bun.sh
    source "${SCRIPT_DIR}/runtime/bun.sh"
    ldw_runtime_install_bun
    ;;
  node)
    # shellcheck source=runtime/node-nvm.sh
    source "${SCRIPT_DIR}/runtime/node-nvm.sh"
    ldw_runtime_install_node_nvm
    ;;
  deno)
    # shellcheck source=runtime/deno.sh
    source "${SCRIPT_DIR}/runtime/deno.sh"
    ldw_runtime_install_deno
    ;;
  ""|none)
    ldw_log "Skipping language runtime (INSTALL_RUNTIME empty or none)."
    ;;
  *)
    ldw_warn "Unknown INSTALL_RUNTIME value '${INSTALL_RUNTIME}'; skipping."
    ;;
esac

# --- Package managers (often depend on Node/bun; order may matter) ---
case "${INSTALL_PKG_MANAGER}" in
  pnpm)
    # shellcheck source=pkg-manager/pnpm.sh
    source "${SCRIPT_DIR}/pkg-manager/pnpm.sh"
    ldw_pkg_install_pnpm
    ;;
  bun)
    # shellcheck source=pkg-manager/bun-pm.sh
    source "${SCRIPT_DIR}/pkg-manager/bun-pm.sh"
    ldw_pkg_use_bun_as_pm
    ;;
  yarn)
    # shellcheck source=pkg-manager/yarn-berry.sh
    source "${SCRIPT_DIR}/pkg-manager/yarn-berry.sh"
    ldw_pkg_install_yarn_berry
    ;;
  npm)
    # shellcheck source=pkg-manager/npm.sh
    source "${SCRIPT_DIR}/pkg-manager/npm.sh"
    ldw_pkg_ensure_npm
    ;;
  ""|none)
    ldw_log "Skipping package manager setup (INSTALL_PKG_MANAGER empty or none)."
    ;;
  *)
    ldw_warn "Unknown INSTALL_PKG_MANAGER value '${INSTALL_PKG_MANAGER}'; skipping."
    ;;
esac

# --- Editors ---
case "${INSTALL_EDITOR}" in
  vscode)
    # shellcheck source=editor/vscode.sh
    source "${SCRIPT_DIR}/editor/vscode.sh"
    ldw_editor_install_vscode
    ;;
  neovim)
    # shellcheck source=editor/neovim-lazy.sh
    source "${SCRIPT_DIR}/editor/neovim-lazy.sh"
    ldw_editor_install_neovim_lazy
    ;;
  helix)
    # shellcheck source=editor/helix.sh
    source "${SCRIPT_DIR}/editor/helix.sh"
    ldw_editor_install_helix
    ;;
  cursor)
    # shellcheck source=editor/cursor.sh
    source "${SCRIPT_DIR}/editor/cursor.sh"
    ldw_editor_install_cursor
    ;;
  ""|none)
    ldw_log "Skipping editor (INSTALL_EDITOR empty or none)."
    ;;
  *)
    ldw_warn "Unknown INSTALL_EDITOR value '${INSTALL_EDITOR}'; skipping."
    ;;
esac

# --- Extras (comma-separated) ---
if [[ -n "${INSTALL_EXTRAS}" && "${INSTALL_EXTRAS}" != "none" ]]; then
  _ldw_extra_trimmed="${INSTALL_EXTRAS//[[:space:]]/}"
  IFS=',' read -r -a _ldw_extras_arr <<< "${_ldw_extra_trimmed}"
  for _extra in "${_ldw_extras_arr[@]}"; do
    [[ -z "${_extra}" ]] && continue
    case "${_extra}" in
      docker)
        # shellcheck source=common/docker.sh
        source "${SCRIPT_DIR}/common/docker.sh"
        ldw_common_install_docker
        ;;
      git)
        # shellcheck source=common/git.sh
        source "${SCRIPT_DIR}/common/git.sh"
        ldw_common_install_git
        ;;
      starship)
        # shellcheck source=common/starship.sh
        source "${SCRIPT_DIR}/common/starship.sh"
        ldw_common_install_starship
        ;;
      nerd-fonts|nerdfonts)
        # shellcheck source=common/nerd-fonts.sh
        source "${SCRIPT_DIR}/common/nerd-fonts.sh"
        ldw_common_install_nerd_fonts
        ;;
      tailscale)
        # shellcheck source=common/extras-tailscale.sh
        source "${SCRIPT_DIR}/common/extras-tailscale.sh"
        ldw_extra_install_tailscale
        ;;
      1password-cli|1password)
        # shellcheck source=common/extras-1password-cli.sh
        source "${SCRIPT_DIR}/common/extras-1password-cli.sh"
        ldw_extra_install_1password_cli
        ;;
      rustup)
        # shellcheck source=common/extras-rustup.sh
        source "${SCRIPT_DIR}/common/extras-rustup.sh"
        ldw_extra_install_rustup
        ;;
      go|golang)
        # shellcheck source=common/extras-go.sh
        source "${SCRIPT_DIR}/common/extras-go.sh"
        ldw_extra_install_go
        ;;
      python|uv)
        # shellcheck source=common/extras-python.sh
        source "${SCRIPT_DIR}/common/extras-python.sh"
        ldw_extra_install_python_tooling
        ;;
      postman)
        # shellcheck source=common/extras-postman.sh
        source "${SCRIPT_DIR}/common/extras-postman.sh"
        ldw_extra_install_postman
        ;;
      insomnia)
        # shellcheck source=common/extras-insomnia.sh
        source "${SCRIPT_DIR}/common/extras-insomnia.sh"
        ldw_extra_install_insomnia
        ;;
      browser)
        # shellcheck source=common/extras-browser.sh
        source "${SCRIPT_DIR}/common/extras-browser.sh"
        ldw_extra_install_browser_dispatch
        ;;
      chrome)
        # shellcheck source=common/extras-browser.sh
        source "${SCRIPT_DIR}/common/extras-browser.sh"
        ldw_extra_install_browser_google_chrome
        ;;
      edge)
        # shellcheck source=common/extras-browser.sh
        source "${SCRIPT_DIR}/common/extras-browser.sh"
        ldw_extra_install_browser_microsoft_edge
        ;;
      firefox)
        # shellcheck source=common/extras-browser.sh
        source "${SCRIPT_DIR}/common/extras-browser.sh"
        ldw_extra_install_browser_firefox
        ;;
      chromium)
        # shellcheck source=common/extras-browser.sh
        source "${SCRIPT_DIR}/common/extras-browser.sh"
        ldw_extra_install_browser_chromium
        ;;
      user-sudo|sudo-group)
        # shellcheck source=common/extras-user-sudo.sh
        source "${SCRIPT_DIR}/common/extras-user-sudo.sh"
        ldw_extra_user_add_to_sudo_group
        ;;
      docker-compose)
        ldw_warn "docker-compose: use Docker with compose plugin (extras: docker); skipping legacy alias."
        ;;
      *)
        ldw_warn "Unknown extra '${_extra}' in INSTALL_EXTRAS; skipping."
        ;;
    esac
  done
fi

if ldw_have_apt; then
  ldw_apt_clean
fi

ldw_log "Linux Dev Wizard — finished successfully."
