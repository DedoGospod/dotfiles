# ======================
# Shell-Specific Logic
# ======================

# Set XDG paths according to the XDG Base Directory Specification
export XDG_DATA_HOME="$HOME/.local/share"       # User-specific data files
export XDG_CONFIG_HOME="$HOME/.config"          # User-specific configuration files
export XDG_STATE_HOME="$HOME/.local/state"      # User-specific state files (logs, history)
export XDG_CACHE_HOME="$HOME/.cache"            # User-specific non-essential cached files

# Store zsh history
export HISTFILE="${XDG_STATE_HOME}/zsh/history" 

# Create these directories if they don't exist (-p flag prevents errors if directories already exist)
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

# ======================
# Auto-Start Logic
# ======================

# This MUST stay here to actually trigger the session.
[ "$(tty)" = "/dev/tty1" ] && exec uwsm start hyprland
[ "$(tty)" = "/dev/tty2" ] && ~/.local/bin/launch-gamescope
