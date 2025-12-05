# ======================
# XDG Base Directory Enforcement
# ======================

# Set XDG paths according to the XDG Base Directory Specification
export XDG_DATA_HOME="$HOME/.local/share"    # User-specific data files
export XDG_CONFIG_HOME="$HOME/.config"       # User-specific configuration files
export XDG_STATE_HOME="$HOME/.local/state"   # User-specific state files (logs, history)
export XDG_CACHE_HOME="$HOME/.cache"         # User-specific non-essential cached files

# Application-specific XDG paths
export CARGO_HOME="$XDG_DATA_HOME/cargo"                              # Rust package manager
export GNUPGHOME="$XDG_DATA_HOME/gnupg"                               # GnuPG (encryption)
export PYTHONHISTORY="$XDG_STATE_HOME/python/history"                 # Python command history
export HISTFILE="${XDG_STATE_HOME}/zsh/history"                       # Store zsh history
export ZSH_COMPDUMP="${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}"  # Store zsh cache file for completions

# Create these directories if they don't exist (-p flag prevents errors if directories already exist)
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

# Theme for qt applications
export QT_QPA_PLATFORMTHEME="qt6ct" # For QT6 applications

# Auto-Start compositors 
[ "$(tty)" = "/dev/tty1" ] && exec uwsm start Hyprland          # Autostart hyprland on tty1
[ "$(tty)" = "/dev/tty2" ] && ~/.local/bin/launch-gamescope.sh  # Autostart gamescope on tty2
