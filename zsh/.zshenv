# (Every Zsh Instance): This is sourced for every instance of Zsh—interactive shells, non-interactive scripts, and subshells.

# --- XDG Base Directory Fallbacks ---
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# --- Application Redirects ---
export CARGO_HOME="${CARGO_HOME:-$XDG_DATA_HOME/cargo}"
export GNUPGHOME="${GNUPGHOME:-$XDG_DATA_HOME/gnupg}"
export PYTHONHISTORY="${PYTHONHISTORY:-$XDG_STATE_HOME/python/history}"

# --- ZSH Specific ---
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# Ensure necessary sub-directories exist
if [[ -o interactive ]]; then
  [[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
  [[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
fi

# Editor preferences
export EDITOR="nvim"                  # Set Neovim as default editor
export SUDO_EDITOR="$EDITOR"          # Editor for sudo operations
export VISUAL="$EDITOR"               # Set VISUAL to nvim for applications that prefer this
export MANPAGER='nvim +Man!'          # Use Neovim for man pages

# Ensure path contains unique entries and is exported
typeset -Ugx path

# Single source of truth for binary paths
path=(
  "$HOME/.local/bin"
  "$CARGO_HOME/bin"
  "${GOPATH:-$HOME/go}/bin"
  $path
)
