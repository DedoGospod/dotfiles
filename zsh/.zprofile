# ======================
# Shell-Specific Logic
# ======================

# Application-specific XDG paths
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export ZSH_COMPDUMP="${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}"

# Create these directories if they don't exist (-p flag prevents errors if directories already exist)
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

# ======================
# Auto-Start Logic
# ======================

# This MUST stay here to actually trigger the session.
[ "$(tty)" = "/dev/tty1" ] && exec uwsm start hyprland
[ "$(tty)" = "/dev/tty2" ] && ~/.local/bin/launch-gamescope.sh
