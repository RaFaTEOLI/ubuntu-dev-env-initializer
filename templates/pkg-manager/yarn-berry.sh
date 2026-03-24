echo "[linux-dev-wizard] Enabling Yarn Berry..."
corepack enable || true
corepack prepare yarn@stable --activate || npm install -g yarn
