#!/usr/bin/env bash
#
# Compforge bootstrap installer
# Clone or update ~/.compforge, then run scripts/setup/install.sh update.

set -euo pipefail

REPO_URL="${COMPFORGE_REPO_URL:-https://github.com/LooSung/compforge.git}"
INSTALL_DIR="${COMPFORGE_HOME:-$HOME/.compforge}"
BRANCH="${COMPFORGE_BRANCH:-main}"
SETUP_DIR="$INSTALL_DIR/scripts/setup"

cyan() { printf "\033[36m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }
red() { printf "\033[31m%s\033[0m\n" "$*"; }

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    red "Required command not found: $1"
    exit 1
  fi
}

clone_or_update() {
  if [ -d "$INSTALL_DIR/.git" ]; then
    cyan "==> Updating existing Compforge at $INSTALL_DIR"
    git -C "$INSTALL_DIR" fetch --quiet origin "$BRANCH"
    git -C "$INSTALL_DIR" checkout --quiet "$BRANCH"
    git -C "$INSTALL_DIR" pull --ff-only --quiet origin "$BRANCH"
    return
  fi

  if [ -e "$INSTALL_DIR" ]; then
    red "Install path exists but is not a git repository: $INSTALL_DIR"
    yellow "Use a different path: COMPFORGE_HOME=/path/to/compforge bash scripts/setup/bootstrap.sh"
    exit 1
  fi

  cyan "==> Cloning Compforge to $INSTALL_DIR"
  git clone --quiet --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
}

require git
clone_or_update

chmod +x "$SETUP_DIR/"*.sh "$INSTALL_DIR/scripts/ci/"*.sh 2>/dev/null || true

cyan "==> Running scripts/setup/install.sh update"
"$SETUP_DIR/install.sh" update

cyan "==> Running scripts/setup/doctor.sh"
"$SETUP_DIR/doctor.sh"

green "==> Compforge bootstrap complete"
