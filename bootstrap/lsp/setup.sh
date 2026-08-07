#!/usr/bin/env bash

set -ueo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_with() {
    local tool_name="$1"
    shift

    if command_exists "$tool_name"; then
        "$@"
        log_success "$tool_name: Installation completed successfully"
    else
        log_error "not installed $tool_name"
    fi
}

log_info "Starting LSP download..."

# use uv
install_with uv uv tool install pyright
install_with uv uv tool install ruff-lsp
install_with uv uv tool install ty

# use bun
install_with bun bun install -g typescript typescript-language-server
install_with bun bun install -g vscode-langservers-extracted
install_with bun bun install -g yaml-language-server@next
install_with bun bun install -g @tailwindcss/language-server
install_with bun bun install -g @vue/language-server
install_with bun bun install -g @vue/typescript-plugin
install_with bun bun install -g prettier
install_with bun bun install -g sql-language-server
install_with bun bun install -g bash-language-server
install_with bun bun install -g dockerfile-language-server-nodejs
install_with bun bun install -g @microsoft/compose-language-service

# use cargo
install_with cargo cargo install --locked --git https://github.com/estin/simple-completion-language-server.git
install_with cargo cargo install taplo-cli --locked --features lsp

# use rustup
install_with rustup rustup component add rust-analyzer


# use go
# Goは使用しないためコメントアウト
# install_with go go install golang.org/x/tools/gopls@latest
# install_with go go install github.com/go-delve/delve/cmd/dlv@latest
# install_with go go install golang.org/x/tools/cmd/goimports@latest
# install_with go go install github.com/nametake/golangci-lint-langserver@latest
# install_with go go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest


log_info "Installation completed successfully"
