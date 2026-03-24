#!/usr/bin/env bash
# Purpose: Install uv (Python package/tool runner) and Poetry via uv or pipx fallback.
#
# Templating: {{PYTHON_UV_VERSION}}, {{POETRY_VERSION}}

ldw_extra_install_python_tooling() {
  ldw_log "Installing Python tooling (uv + poetry)"

  if ! ldw_command_exists curl; then
    ldw_apt_install curl || true
  fi

  # uv official installer
  if ! ldw_command_exists uv; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="${LDW_HOME}/.local/bin:${PATH}"
  fi

  if ldw_command_exists uv; then
    uv tool install poetry || uv pip install poetry || true
  elif ldw_command_exists pipx; then
    pipx install poetry
  else
    ldw_apt_install python3-pip || true
    python3 -m pip install --user poetry || ldw_warn "Poetry install failed; install manually."
  fi

  ldw_log "Python tooling step complete (restart shell for PATH updates)"
}
