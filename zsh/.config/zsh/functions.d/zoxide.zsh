#!/usr/bin/env zsh

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
