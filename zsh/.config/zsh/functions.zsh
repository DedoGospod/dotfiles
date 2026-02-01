#!/usr/bin/env zsh

# NAVIGATION -------------------------------------------------------------------

# zl: Navigate with 'z' and immediately list directory contents
zl() {
    if [ -z "$@" ]; then
        ls -1 --color=always --group-directories-first
    else
        z "$@" && \
        ls -1 --color=always --group-directories-first
    fi
}

# zlh: Navigate with 'z' and list ALL contents (including hidden)
zlh() {
    if [ -z "$@" ]; then
        ls -1A --color=always --group-directories-first
    else 
        z "$@" && \
        ls -1A --color=always --group-directories-first
    fi
}

# EDITING ----------------------------------------------------------------------

# nv: Smart Neovim wrapper. Uses sudoedit automatically for root-protected files
nv() {
    if [ -z "$1" ]; then
        command nvim
        return
    fi

    local target="$1"
    local dir
    dir=$(dirname "$target")

    if ([ -e "$target" ] && [ ! -w "$target" ]) || ([ ! -e "$target" ] && [ -d "$dir" ] && [ ! -w "$dir" ]); then
        echo "Using sudoedit for root-protected path: $target"
        command sudoedit "$@"
    else
        command nvim "$@"
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
