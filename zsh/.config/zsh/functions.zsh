#!/usr/bin/env zsh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
usage()   { echo -e "${CYAN}[Usage]${NC} $1"; } 
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# NAVIGATION -------------------------------------------------------------------

# zl: Navigate with 'z' and immediately list directory contents
zl() {
    if [[ -z "$@" ]]; then
        ls -1 --color=always --group-directories-first
    else
        z "$@" && \
        ls -1 --color=always --group-directories-first
    fi
}

# zlh: Navigate with 'z' and list ALL contents (including hidden)
zlh() {
    if [[ -z "$@" ]]; then
        ls -1A --color=always --group-directories-first
    else 
        z "$@" && \
        ls -1A --color=always --group-directories-first
    fi
}

# EDITING ----------------------------------------------------------------------

# nv: Smart Neovim wrapper. Uses sudoedit automatically for root-protected files
nv() {
    if [[ -z "$1" ]]; then
        command nvim
        return
    fi

    local target="$1"
    local dir="$(dirname "$target")"

    if [[ ( -e "$target" && ! -w "$target" ) || ( ! -e "$target" && -d "$dir" && ! -w "$dir" ) ]]; then
        echo "Using sudoedit for root-protected path: $target"
        command sudoedit "$@"
    else
        command nvim "$@"
    fi
}

tldr() {
    if [[ -n "$1" ]]; then
        command tldr "$@" | nvim -R -c "set ft=help" -
    else
        error  "Please provide a command"
        usage " tldr <package>"
        return 1
    fi
}

# GIT --------------------------------------------------------------------------

# ga: Stage files (defaults to all) and show status
ga() {
    git add "${@:-.}"
    git status
}

# gm: Sync main with origin, merge 'testing' into 'main', and push
gm() {
    (
        set -e
        git switch main
        git pull --rebase origin main
        GIT_MERGE_AUTOEDIT=no git merge testing --no-edit
        git push origin main
        git switch testing
    )
}

# Custom Snapper manual snapshot function
snapper-create() {

    if [[ -z "$1" ]]; then
        error "Please provide a description."
        usage "snapper-create <description>"
        return 1
    fi

    sudo snapper -c root create --description "$1" --cleanup-algorithm number
    success "Snapshot created: $1"
}
