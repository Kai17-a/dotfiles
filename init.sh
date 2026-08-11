#!/usr/bin/env bash

set -ueo pipefail

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

collect_dotfile_conflicts() {
    "$DOTFILE_DIR/bin/mise" -C "$DOTFILE_DIR" bootstrap dotfiles status |
        awk '$4 == "differs" { print $1 }'
}

backup_dotfile_conflicts() {
    local -a targets
    local answer
    local conflicts
    local backup_parent
    local backup_dir
    local target
    local target_path
    local relative_path
    local backup_path

    if ! conflicts="$(collect_dotfile_conflicts)"; then
        echo "[ERROR] Failed to inspect managed dotfiles. Setup cancelled."
        return 1
    fi

    targets=()
    if [[ -n "$conflicts" ]]; then
        mapfile -t targets <<< "$conflicts"
    fi

    if (( ${#targets[@]} == 0 )); then
        return
    fi

    echo "[WARN] Existing files conflict with managed dotfiles:"
    printf '  %s\n' "${targets[@]}"

    if ! read -r -p "Move these files to a backup before continuing? [Y/n] " answer; then
        echo "[ERROR] Confirmation input is unavailable. Setup cancelled."
        return 1
    fi
    case "$answer" in
        ""|y|Y)
            ;;
        n|N)
            echo "[INFO] Setup cancelled. No files were moved."
            return 1
            ;;
        *)
            echo "[ERROR] Expected Y or n. Setup cancelled."
            return 1
            ;;
    esac

    backup_parent="$HOME/.dotfiles-backups"
    mkdir -p "$backup_parent"
    backup_dir="$(mktemp -d "$backup_parent/$(date +%Y%m%d-%H%M%S).XXXXXX")"

    for target in "${targets[@]}"; do
        target_path="${target/#\~/$HOME}"
        relative_path="${target_path#"$HOME"/}"
        backup_path="$backup_dir/$relative_path"

        mkdir -p "$(dirname "$backup_path")"
        mv -- "$target_path" "$backup_path"
        echo "[INFO] Moved $target to $backup_path"
    done

    echo "[INFO] Existing dotfiles were backed up to $backup_dir"
}

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
    backup_dotfile_conflicts
    "$DOTFILE_DIR/bin/mise" -C "$DOTFILE_DIR" bootstrap --yes --update
    configure_github
}

main
