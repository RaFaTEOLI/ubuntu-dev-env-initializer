echo "[linux-dev-wizard] Enabling pnpm..."
corepack enable || true
corepack prepare pnpm@latest --activate || npm install -g pnpm
