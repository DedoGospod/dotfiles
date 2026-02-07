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

# Executable search paths
export PATH="$HOME/.local/bin:$PATH"  # User scripts and local binaries
export PATH="$CARGO_HOME/bin:$PATH"   # Rust/Cargo binaries (XDG compliant)

# Configure path
typeset -Ugx path
path=(
  "$HOME/.local/bin"
  "$CARGO_HOME/bin"
  $path
)
# Export the tied PATH string so other apps can see it
export PATH
