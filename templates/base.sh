#!/usr/bin/env bash
# Purpose: Shared helpers for Linux Dev Wizard — sudo detection, one-shot APT refresh,
#          safe installs, logging, and cleanup. Sourced by main.sh and feature modules.
#
# Templating: the generator may replace placeholders such as {{LDW_DISTRO_CODENAME}}
#             before the user runs the final script.

set -euo pipefail

# --- Optional metadata (substituted by web generator) ---
# {{LDW_GENERATED_AT}}
# {{LDW_PROFILE_NAME}}

# Prevent double-sourcing base logic
if [[ -n "${_LDW_BASE_LOADED:-}" ]]; then
  return 0
fi
readonly _LDW_BASE_LOADED=1

# Distro hint for downstream scripts (Debian/Ubuntu). Generator may override.
: "${LDW_DISTRO_CODENAME:=$(. /etc/os-release 2>/dev/null && echo "${VERSION_CODENAME:-}")}"

# --- Logging ---

ldw_log() {
  printf '\n[\033[0;36mldw\033[0m] %s\n' "$*"
}

ldw_warn() {
  printf '\n[\033[0;33mldw:warn\033[0m] %s\n' "$*" >&2
}

ldw_die() {
  printf '\n[\033[0;31mldw:error\033[0m] %s\n' "$*" >&2
  exit 1
}

# --- Privilege / sudo ---

# Ensure we can run apt and other privileged steps without repeated password prompts.
ldw_require_sudo() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    ldw_warn "Running as root; sudo not required."
    return 0
  fi
  if ! command -v sudo >/dev/null 2>&1; then
    ldw_die "sudo is not installed. Install it or run as root."
  fi
  if ! sudo -n true 2>/dev/null; then
    ldw_log "Requesting sudo for privileged operations..."
    sudo -v
  fi
  # Keep sudo alive for long installs (background refresh every 60s).
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  _LDW_SUDO_KEEPALIVE_PID=$!
}

ldw_sudo_cleanup() {
  if [[ -n "${_LDW_SUDO_KEEPALIVE_PID:-}" ]]; then
    kill "${_LDW_SUDO_KEEPALIVE_PID}" 2>/dev/null || true
  fi
}

trap ldw_sudo_cleanup EXIT

# --- Command / path helpers ---

ldw_command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ldw_have_apt() {
  ldw_command_exists apt-get
}

# --- APT: single update, no-install-recommends, optional clean ---

_LDW_APT_UPDATED=0

ldw_apt_update() {
  ldw_require_sudo
  if [[ "${_LDW_APT_UPDATED}" -eq 1 ]]; then
    return 0
  fi
  ldw_log "apt-get update (once per session)"
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
  _LDW_APT_UPDATED=1
}

# Install packages with modern defaults; idempotent.
ldw_apt_install() {
  ldw_apt_update
  ldw_log "apt-get install: $*"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

# Remove cached package lists to save disk (safe on single-user machines).
ldw_apt_clean() {
  if ! ldw_have_apt; then
    return 0
  fi
  ldw_log "apt-get clean (optional cache trim)"
  sudo apt-get clean -y || true
  sudo rm -rf /var/lib/apt/lists/* 2>/dev/null || true
}

# --- User-facing home (respect SUDO_USER when running under sudo) ---

ldw_real_user_home() {
  if [[ -n "${SUDO_USER:-}" ]]; then
    getent passwd "${SUDO_USER}" | cut -d: -f6
  else
    printf '%s' "${HOME}"
  fi
}

readonly LDW_HOME="$(ldw_real_user_home)"

# --- Script root (directory containing templates/) when sourced from main ---

: "${LDW_TEMPLATE_ROOT:=}"

ldw_template_dir() {
  if [[ -n "${LDW_TEMPLATE_ROOT}" ]]; then
    printf '%s' "${LDW_TEMPLATE_ROOT}"
    return
  fi
  # Fallback: parent of the file that sourced base (best-effort).
  printf '%s' "$(cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")/.." && pwd)"
}
