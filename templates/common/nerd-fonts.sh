#!/usr/bin/env bash
# Purpose: Download selected Nerd Fonts releases into ~/.local/share/fonts and refresh cache.
#          Idempotent: skips download if the font family directory already exists.
#
# Env:
#   NERD_FONT_RELEASE — GitHub release tag (default: v3.2.1)
#   NERD_FONT_FAMILIES — space-separated zip names without .zip (default: JetBrainsMono FiraCode)
#
# Templating: {{NERD_FONT_RELEASE}}, {{NERD_FONT_FAMILIES}}

ldw_common_install_nerd_fonts() {
  ldw_log "Installing Nerd Fonts (user-local)"

  : "${NERD_FONT_RELEASE:=v3.2.1}"
  : "${NERD_FONT_FAMILIES:=JetBrainsMono FiraCode}"

  ldw_apt_install wget unzip fontconfig

  local base_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_RELEASE}"
  local font_root="${LDW_HOME}/.local/share/fonts"
  mkdir -p "${font_root}"

  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "${tmp}"' RETURN

  local family
  for family in ${NERD_FONT_FAMILIES}; do
    local dest="${font_root}/NerdFonts-${family}"
    if [[ -d "${dest}" ]] && [[ -n "$(ls -A "${dest}" 2>/dev/null)" ]]; then
      ldw_log "Font family already present: ${family}; skipping"
      continue
    fi

    mkdir -p "${dest}"
    ldw_log "Downloading ${family}.zip"
    wget -q "${base_url}/${family}.zip" -O "${tmp}/${family}.zip"
    unzip -oq "${tmp}/${family}.zip" -d "${dest}"
    rm -f "${tmp}/${family}.zip"
  done

  if ldw_command_exists fc-cache; then
    fc-cache -f "${font_root}" || true
  fi

  ldw_log "Nerd Fonts installed under ${font_root}"
}
