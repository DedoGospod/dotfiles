#!/usr/bin/env bash

# System Scripts
DOTFILES_DIR="$HOME/dotfiles"
SYSTEM_SRC="$DOTFILES_DIR/scripts/system-scripts"

if [ -d "$SYSTEM_SRC" ]; then
    log "Syncing system scripts..."

    # Define the files to sync ( Format: "source_relative_to_SYSTEM_SRC|target_absolute_path")
    SYSTEM_FILES=(
        "etc/cron.weekly/btrfs-clean-job|/etc/cron.weekly/btrfs-clean-job"
        "etc/cron.weekly/clean-pkg-managers|/etc/cron.weekly/clean-pkg-managers"
        "usr/local/bin/reboot-to-windows|/usr/local/bin/reboot-to-windows"
    )

    for entry in "${SYSTEM_FILES[@]}"; do
        src="${entry%%|*}"
        target="${entry##*|}"
        full_src="$SYSTEM_SRC/$src"

        if [ -f "$full_src" ]; then
            log_task "Installing $target"
            sudo install -Dm 755 "$full_src" "$target" && echo -e "${GREEN}Done.${NC}" || echo -e "${RED}Failed.${NC}"
        else
            warn "Source file not found: $src"
        fi
    done
else
    warn "System scripts directory not found at $SYSTEM_SRC."
fi
