#!/usr/bin/env bash
# Purpose: Central module selection registry used by main.sh, preview, and script generation.
# Inputs: INSTALL_* env vars.
# Outputs:
#   - LDW_PLAN_FILES: ordered list of template files to source/include
#   - LDW_PLAN_CALLS: ordered list of function calls to execute

ldw_registry_warn() {
  if declare -F ldw_warn >/dev/null 2>&1; then
    ldw_warn "$*"
  else
    printf '[ldw:warn] %s\n' "$*" >&2
  fi
}

ldw_registry_add() {
  local file="$1"
  local call="$2"
  LDW_PLAN_FILES+=("${file}")
  LDW_PLAN_CALLS+=("${call}")
}

ldw_registry_plan_modules() {
  local script_dir="$1"

  LDW_PLAN_FILES=()
  LDW_PLAN_CALLS=()

  # Shell
  case "${INSTALL_SHELL}" in
    zsh) ldw_registry_add "${script_dir}/shell/zsh.sh" "ldw_shell_install_zsh" ;;
    fish) ldw_registry_add "${script_dir}/shell/fish.sh" "ldw_shell_install_fish" ;;
    bash) ldw_registry_add "${script_dir}/shell/bash.sh" "ldw_shell_install_bash_enhancements" ;;
    ""|none) ;;
    *) ldw_registry_warn "Unknown INSTALL_SHELL value '${INSTALL_SHELL}'; skipping." ;;
  esac

  # Terminal
  case "${INSTALL_TERMINAL}" in
    wezterm) ldw_registry_add "${script_dir}/terminal/wezterm.sh" "ldw_terminal_install_wezterm" ;;
    kitty) ldw_registry_add "${script_dir}/terminal/kitty.sh" "ldw_terminal_install_kitty" ;;
    alacritty) ldw_registry_add "${script_dir}/terminal/alacritty.sh" "ldw_terminal_install_alacritty" ;;
    hyper) ldw_registry_add "${script_dir}/terminal/hyper.sh" "ldw_terminal_install_hyper" ;;
    ""|none) ;;
    *) ldw_registry_warn "Unknown INSTALL_TERMINAL value '${INSTALL_TERMINAL}'; skipping." ;;
  esac

  # Runtimes
  case "${INSTALL_RUNTIME}" in
    bun) ldw_registry_add "${script_dir}/runtime/bun.sh" "ldw_runtime_install_bun" ;;
    node) ldw_registry_add "${script_dir}/runtime/node-nvm.sh" "ldw_runtime_install_node_nvm" ;;
    deno) ldw_registry_add "${script_dir}/runtime/deno.sh" "ldw_runtime_install_deno" ;;
    ""|none) ;;
    *) ldw_registry_warn "Unknown INSTALL_RUNTIME value '${INSTALL_RUNTIME}'; skipping." ;;
  esac

  # Package managers
  case "${INSTALL_PKG_MANAGER}" in
    pnpm) ldw_registry_add "${script_dir}/pkg-manager/pnpm.sh" "ldw_pkg_install_pnpm" ;;
    bun) ldw_registry_add "${script_dir}/pkg-manager/bun-pm.sh" "ldw_pkg_use_bun_as_pm" ;;
    yarn) ldw_registry_add "${script_dir}/pkg-manager/yarn-berry.sh" "ldw_pkg_install_yarn_berry" ;;
    npm) ldw_registry_add "${script_dir}/pkg-manager/npm.sh" "ldw_pkg_ensure_npm" ;;
    ""|none) ;;
    *) ldw_registry_warn "Unknown INSTALL_PKG_MANAGER value '${INSTALL_PKG_MANAGER}'; skipping." ;;
  esac

  # Editors
  case "${INSTALL_EDITOR}" in
    vscode) ldw_registry_add "${script_dir}/editor/vscode.sh" "ldw_editor_install_vscode" ;;
    neovim) ldw_registry_add "${script_dir}/editor/neovim-lazy.sh" "ldw_editor_install_neovim_lazy" ;;
    helix) ldw_registry_add "${script_dir}/editor/helix.sh" "ldw_editor_install_helix" ;;
    cursor) ldw_registry_add "${script_dir}/editor/cursor.sh" "ldw_editor_install_cursor" ;;
    ""|none) ;;
    *) ldw_registry_warn "Unknown INSTALL_EDITOR value '${INSTALL_EDITOR}'; skipping." ;;
  esac

  # Extras
  if [[ -n "${INSTALL_EXTRAS}" && "${INSTALL_EXTRAS}" != "none" ]]; then
    local extras_trimmed
    extras_trimmed="${INSTALL_EXTRAS//[[:space:]]/}"
    local extra
    IFS=',' read -r -a _ldw_extras_arr <<< "${extras_trimmed}"
    for extra in "${_ldw_extras_arr[@]}"; do
      [[ -z "${extra}" ]] && continue
      case "${extra}" in
        docker) ldw_registry_add "${script_dir}/common/docker.sh" "ldw_common_install_docker" ;;
        git) ldw_registry_add "${script_dir}/common/git.sh" "ldw_common_install_git" ;;
        starship) ldw_registry_add "${script_dir}/common/starship.sh" "ldw_common_install_starship" ;;
        nerd-fonts) ldw_registry_add "${script_dir}/common/nerd-fonts.sh" "ldw_common_install_nerd_fonts" ;;
        tailscale) ldw_registry_add "${script_dir}/common/extras-tailscale.sh" "ldw_extra_install_tailscale" ;;
        1password-cli|1password) ldw_registry_add "${script_dir}/common/extras-1password-cli.sh" "ldw_extra_install_1password_cli" ;;
        rustup) ldw_registry_add "${script_dir}/common/extras-rustup.sh" "ldw_extra_install_rustup" ;;
        go|golang) ldw_registry_add "${script_dir}/common/extras-go.sh" "ldw_extra_install_go" ;;
        python|uv) ldw_registry_add "${script_dir}/common/extras-python.sh" "ldw_extra_install_python_tooling" ;;
        postman) ldw_registry_add "${script_dir}/common/extras-postman.sh" "ldw_extra_install_postman" ;;
        insomnia) ldw_registry_add "${script_dir}/common/extras-insomnia.sh" "ldw_extra_install_insomnia" ;;
        browser) ldw_registry_add "${script_dir}/common/extras-browser.sh" "ldw_extra_install_browser_dispatch" ;;
        chrome) ldw_registry_add "${script_dir}/common/extras-browser.sh" "ldw_extra_install_browser_google_chrome" ;;
        edge) ldw_registry_add "${script_dir}/common/extras-browser.sh" "ldw_extra_install_browser_microsoft_edge" ;;
        firefox) ldw_registry_add "${script_dir}/common/extras-browser.sh" "ldw_extra_install_browser_firefox" ;;
        chromium) ldw_registry_add "${script_dir}/common/extras-browser.sh" "ldw_extra_install_browser_chromium" ;;
        user-sudo|sudo-group) ldw_registry_add "${script_dir}/common/extras-user-sudo.sh" "ldw_extra_user_add_to_sudo_group" ;;
        docker-compose) ldw_registry_warn "docker-compose: use Docker with compose plugin (extras: docker); skipping legacy alias." ;;
        *) ldw_registry_warn "Unknown extra '${extra}' in INSTALL_EXTRAS; skipping." ;;
      esac
    done
  fi

  # De-duplicate pairs while preserving order.
  local dedup_files=()
  local dedup_calls=()
  local key
  local i
  declare -A seen=()
  for i in "${!LDW_PLAN_FILES[@]}"; do
    key="${LDW_PLAN_FILES[$i]}::${LDW_PLAN_CALLS[$i]}"
    if [[ -z "${seen[${key}]:-}" ]]; then
      seen["${key}"]=1
      dedup_files+=("${LDW_PLAN_FILES[$i]}")
      dedup_calls+=("${LDW_PLAN_CALLS[$i]}")
    fi
  done

  LDW_PLAN_FILES=("${dedup_files[@]}")
  LDW_PLAN_CALLS=("${dedup_calls[@]}")
}
