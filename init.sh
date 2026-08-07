#!/usr/bin/env bash

set -ueo pipefail

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
    "$DOTFILE_DIR/bin/mise" trust "$DOTFILE_DIR/.config/mise/config.toml"
    "$DOTFILE_DIR/bin/mise" -C "$DOTFILE_DIR" bootstrap --yes --update

    echo "[INFO] If GitHub CLI is not authenticated yet, run:"
    echo "  gh auth login --hostname github.com"
}

main
