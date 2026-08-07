#!/usr/bin/env bash

set -ueo pipefail

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

configure_github() {
    if ! command -v gh >/dev/null 2>&1; then
        echo "[WARN] GitHub CLI is unavailable. Install gh, then run:"
        echo "  gh auth login --hostname github.com --git-protocol ssh --web"
        return
    fi

    if ! gh auth status --hostname github.com >/dev/null 2>&1; then
        echo "[WARN] GitHub CLI is not authenticated. Run:"
        echo "  gh auth login --hostname github.com --git-protocol ssh --web"
        return
    fi

    gh config set git_protocol ssh --host github.com
    echo "[INFO] GitHub CLI is authenticated and configured to use SSH."
}

main() {
    "$DOTFILE_DIR/bin/mise" trust "$DOTFILE_DIR/.config/mise/config.toml"
    "$DOTFILE_DIR/bin/mise" -C "$DOTFILE_DIR" bootstrap --yes --update
    configure_github
}

main
