#!/usr/bin/env zsh

### Custom Zsh Functions ###

# Automatically do an ls after each zl command
zl() {
    if [ -z "$@" ]; then
        ls -1 --color=always --group-directories-first
    else
        z "$@" && \
        ls -1 --color=always --group-directories-first
    fi;
}

# Show hidden files when listing with zl
zlh() {
    if [ -z "$@" ]; then
        ls -1A --color=always --group-directories-first
    else 
        z "$@" && \
        ls -1A --color=always --group-directories-first
    fi
}

# Nv command works for root and user files without the need to type 'sudo'
nv() {
    # If no argument is provided, just open Neovim
    if [ -z "$1" ]; then
        command nvim
        return
    fi

    local target="$1"
    local dir
    dir=$(dirname "$target")

    # Use sudoedit if the file exists and isn't writable, OR the file doesn't exist but the directory isn't writable
    if ([ -e "$target" ] && [ ! -w "$target" ]) || ([ ! -e "$target" ] && [ -d "$dir" ] && [ ! -w "$dir" ]); then
        echo "Using sudoedit for root-protected path: $target"
        command sudoedit "$@"
    else
        command nvim "$@"
    fi
}

# git add + git status in one command
ga() {
    git add "${@:-.}"
    git status
}

# Merge branches and switch bash to testing branch
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
