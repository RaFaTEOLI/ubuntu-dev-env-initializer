#!/usr/bin/env bash
set -euo pipefail

echo "[linux-dev-wizard] Starting setup for {{DISTRO}}..."

sudo apt-get update
sudo apt-get install -y curl ca-certificates gnupg
