echo "[linux-dev-wizard] Installing Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER" || true
