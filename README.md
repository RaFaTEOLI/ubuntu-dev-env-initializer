# Ubuntu Dev Env Initializer

**Linux Dev Wizard** — modular Bash templates for **Ubuntu** and **Debian** that install a tailored developer stack from a single entrypoint. Choices are driven by **environment variables** (no interactive prompts in `main.sh`). The same fragments are easy to **concatenate or substitute** from a web app or CI (e.g. `{{INSTALL_SHELL}}`, `envsubst`).

---

## What’s in the repo

| Path | Role |
|------|------|
| `templates/main.sh` | Entry script: sources `base.sh`, then optional modules by `INSTALL_*` |
| `templates/base.sh` | Shared helpers: sudo, one-shot `apt-get update`, logging, `LDW_HOME` |
| `templates/{shell,terminal,runtime,pkg-manager,editor,common}/` | One concern per file; each defines `ldw_*` functions |
| `generate-preview.sh` | **Dry run**: prints env + list of template files that would be sourced |
| `config/` | Optional assets (e.g. `.hyper.js`) referenced via env vars in templates |

Run **`main.sh` on a real system** (VM or container first). **`generate-preview.sh`** never installs anything.

---

## Requirements

- Ubuntu or Debian with **`apt`**
- **`sudo`** for package installs
- **Bash** (scripts use `set -euo pipefail` and modern patterns)

---

## Quick start

**1. Preview (safe)**

```bash
chmod +x generate-preview.sh
INSTALL_SHELL=zsh INSTALL_TERMINAL=wezterm INSTALL_RUNTIME=bun \
  INSTALL_PKG_MANAGER=pnpm INSTALL_EDITOR=vscode \
  INSTALL_EXTRAS=docker,git,starship ./generate-preview.sh
```

**2. Install (destructive — use a throwaway VM first)**

```bash
chmod +x templates/main.sh
cd templates
export INSTALL_SHELL=zsh INSTALL_EXTRAS=docker,git
./main.sh
```

---

## Configuration variables

Unset or empty means **skip** that block (no surprise installs).

### Main choices

| Variable | Values (examples) |
|----------|---------------------|
| `INSTALL_SHELL` | `zsh`, `fish`, `bash`, or empty / `none` |
| `INSTALL_TERMINAL` | `wezterm`, `kitty`, `alacritty`, `hyper`, or empty / `none` |
| `INSTALL_RUNTIME` | `bun`, `node` (nvm + LTS), `deno`, or empty / `none` |
| `INSTALL_PKG_MANAGER` | `pnpm`, `bun`, `yarn`, `npm`, or empty / `none` |
| `INSTALL_EDITOR` | `vscode`, `cursor`, `neovim`, `helix`, or empty / `none` |
| `INSTALL_EXTRAS` | Comma-separated tokens (see table below) |
| `INSTALL_BROWSER` | Used with extra `browser`: `chrome`, `edge`, `firefox`, `chromium` (default `chrome`) |

### `INSTALL_EXTRAS` tokens

| Token | What it installs |
|-------|------------------|
| `docker` | Docker Engine + Compose plugin (official repos) |
| `git` | Git, Git LFS, optional GitHub CLI (`GIT_INSTALL_GH=yes`), optional SSH (`GIT_SSH_*` — see `templates/common/git.sh`) |
| `starship` | Starship prompt (respects `INSTALL_SHELL`) |
| `nerd-fonts` / `nerdfonts` | Nerd Fonts under `~/.local/share/fonts` |
| `tailscale` | Tailscale (official install script) |
| `1password` / `1password-cli` | 1Password CLI (APT) |
| `rustup` | Rust via rustup |
| `go` / `golang` | Go toolchain under `/usr/local/go` |
| `python` / `uv` | `uv` + Poetry-style tooling |
| `postman` | Postman (tarball under `/opt`) |
| `insomnia` | Insomnia (`.deb` from GitHub releases) |
| `browser` | One browser via `INSTALL_BROWSER` |
| `chrome`, `edge`, `firefox`, `chromium` | That browser only |
| `user-sudo` / `sudo-group` | Add current user to `sudo` group if missing |

`docker-compose` as an extra name is ignored with a hint to use `docker` (Compose v2 plugin).

---

## Features (by category)

- **Shells:** Zsh + Oh My Zsh + Powerlevel10k + common plugins; Fish; Bash quality-of-life tweaks  
- **Terminals:** WezTerm, Kitty, Alacritty, Hyper (optional `HYPER_CONFIG_FROM` for `~/.hyper.js`)  
- **Runtimes:** Bun, Node via nvm (LTS), Deno  
- **Package managers:** pnpm (Corepack / npm / install script), Yarn Berry, npm, Bun as PM  
- **Editors:** VS Code (extensions), Cursor, Neovim + LazyVim starter, Helix  
- **Extras:** Docker, Git + SSH helpers, Starship, Nerd Fonts, browsers, API clients (Postman, Insomnia), Tailscale, 1Password CLI, Rust, Go, Python (`uv`), sudo group  

`templates/base.sh` refreshes APT once, uses `apt-get install -y --no-install-recommends` where appropriate, and trims APT cache at the end of `main.sh`.

---

## Git and SSH (optional)

When `git` is in `INSTALL_EXTRAS`, see **`templates/common/git.sh`** for:

- `GIT_USER_NAME`, `GIT_USER_EMAIL`, `GITCONFIG`
- `GIT_INSTALL_GH=yes` for GitHub CLI
- `GIT_SSH_SETUP=yes`, `GIT_SSH_SKIP_PASSPHRASE`, `GIT_SSH_INTERACTIVE`, `GIT_SSH_GH_KEY_TITLE`, etc.

---

## Templating and Next.js

Template files may contain placeholders like `{{INSTALL_SHELL}}` for **`envsubst`**, **`sed`**, or string replace in Node. Runtime behavior still follows **`INSTALL_*` env vars** when you run the scripts as-is.

---

## Caution

These scripts perform **system-level changes** (packages, Docker, default shell, etc.). Review **`templates/`** before use. Prefer a **VM or container** for the first run.
