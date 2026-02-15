#!/usr/bin/env bash
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
