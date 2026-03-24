#!/usr/bin/env bash
# Purpose: Install Docker Engine + CLI + compose plugin from Docker’s official Ubuntu repo.
#          Idempotent: skips if docker is already usable.
#
# Templating: {{DOCKER_CHANNEL}} (stable|test — default stable)

ldw_common_install_docker() {
  if ldw_command_exists docker && docker info >/dev/null 2>&1; then
    ldw_log "Docker already installed and daemon reachable."
    return 0
  fi

  if ! ldw_have_apt; then
    ldw_die "apt not found; Docker installer targets Debian/Ubuntu."
  fi

  ldw_log "Installing Docker Engine (official repository)"

  ldw_apt_install ca-certificates curl gnupg lsb-release

  local docker_distro
  docker_distro="$(. /etc/os-release && echo "${ID:-}")"
  case "${docker_distro}" in
    ubuntu) docker_distro="ubuntu" ;;
    debian) docker_distro="debian" ;;
    *) ldw_die "Docker APT repo not supported for ID=${docker_distro} (use ubuntu|debian)." ;;
  esac

  sudo install -m0755 -d /etc/apt/keyrings
  if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
    curl -fsSL "https://download.docker.com/linux/${docker_distro}/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  fi

  local arch
  arch="$(dpkg --print-architecture)"
  local codename
  codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"
  if [[ -z "${codename}" ]]; then
    ldw_die "Could not detect VERSION_CODENAME from /etc/os-release"
  fi

  echo \
    "deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${docker_distro} ${codename} stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  ldw_apt_update
  ldw_apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Allow current user to use docker without sudo (newgrp applies after re-login)
  if [[ -n "${SUDO_USER:-}" ]]; then
    sudo usermod -aG docker "${SUDO_USER}" || true
    ldw_log "Added ${SUDO_USER} to docker group (log out/in to apply)."
  fi

  ldw_log "Docker installed: $(docker --version 2>/dev/null || true)"
}
