#!/usr/bin/env zsh

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
