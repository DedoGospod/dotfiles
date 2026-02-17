# (Every Zsh Instance): This is sourced for every instance of Zsh—interactive shells, non-interactive scripts, and subshells.

# Define XDG defaults if NOT already set by uwsm/systemd
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Editor Preferences
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export VISUAL="$EDITOR"
export MANPAGER='nvim +Man!'

# Zsh Specific
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# Binary Paths
typeset -Ugx path
path=(
  "$HOME/.local/bin"
  "${CARGO_HOME:-$XDG_DATA_HOME/cargo}/bin"
  "${GOPATH:-$HOME/go}/bin"
  $path
)
