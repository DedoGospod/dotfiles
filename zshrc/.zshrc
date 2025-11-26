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

# ======================
# ZSH Configuration
# ======================

# Create zsh-specifc XDG directories
mkdir -p "${XDG_STATE_HOME}/zsh"                 # Ensure zsh state directory exists 
mkdir -p "${XDG_CACHE_HOME}/zsh"                 # Ensures zsh cache directory exists

# History settings configured to be XDG-compliant
HISTSIZE=10000                                   # Number of commands kept in memory
SAVEHIST=10000                                   # Number of commands saved to HISTFILE
setopt inc_append_history                        # Save commands to history immediately
setopt share_history                             # Sync history across sessions
setopt extended_history                          # Save timestamps
setopt hist_ignore_all_dups                      # Avoid saving any duplicate commands entirely

# Invalid commands dont get stored in history
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

# Initialize ZSH completion system
autoload -Uz compinit 
compinit -d "${ZSH_COMPDUMP}"  # Explicitly use the custom XDG-compliant path

# ======================
# Shell Initialization
# ======================

# Load plugins with existence checks to prevent errors
plugin_dir="/usr/share/zsh/plugins"
[ -f "$plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
    source "$plugin_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "$plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "$plugin_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Initialize tools
eval "$(starship init zsh)"  # Custom shell prompt 
eval "$(zoxide init zsh)"    # Initialize zoxide

# File and directory searching
export FZF_CTRL_T_COMMAND='fd --hidden --exclude .git'                                                          # File search
export FZF_CTRL_T_OPTS=" --preview='bat --color=always --line-range :500 {}' --bind 'enter:execute(nvim {})'"   # Add preview and colors to file search
bindkey -s '^Z' 'zi\n'

# FZF key bindings and completion
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# ======================
# Environment Variables
# ======================

# Editor preferences
export EDITOR="nvim"                  # Set Neovim as default editor
export SUDO_EDITOR="$EDITOR"          # Editor for sudo operations
export VISUAL="$EDITOR"               # Set VISUAL to nvim for applications that prefer this
export MANPAGER='nvim +Man!'          # Use Neovim for man pages

# PATH modifications
mkdir -p "$HOME/.local/bin"           # Create user-local path 
export PATH="$HOME/.local/bin:$PATH"  # Add user-local binaries to PATH

# ======================
# Aliases 
# ======================

# System
alias sudo='sudo '                # Always use sudo explicitly
alias rb='reboot'                 # Reboot system
alias updatemirrors='sudo reflector --verbose --country $(curl -s https://ipinfo.io/country | tr -d "\n") --protocol https --score 5 --sort rate --save /etc/pacman.d/mirrorlist'
alias update-grub="grub-mkconfig -o /boot/grub/grub.cfg"

# Package Management
alias yay='paru'             # Use paru as yay alternative
alias pacman='sudo pacman'   # Always use sudo with pacman


# Apps
alias nv='nvim'                                        # Neovim shortcut
alias snv='sudoedit'                                   # Allow neovim to use my configuration on system files
alias y='yazi'                                         # Use Yazi as a terminal file manager
alias top='btop'                                       # Modern system monitor
alias cls='clear'                                      # Clear screen
alias kssh='kitty +kitten ssh'                         # SSH with kitty terminal features
alias cat='bat'                                        # Use bat instead of cat

# Files
alias cp='cp -i'            # Interactive copy
alias mv='mv -i'            # Interactive move
alias rm='trash -v'         # Safe delete using trash-cli
alias mkdir='mkdir -p'      # Create parent directories automatically
alias ls='ls -1 --color=always --group-directories-first'  # Colorized ls output
alias ll='eza -l'           # Long listing
alias lsh='ls -A'           # Show all files including hidden
alias h='fc -nil 1 | grep'  # Search history for a specific terminal command
alias hist="fc -nil 1"      # Always show history with readable dates
alias du='du -h'
alias df='df -h'
zl() { if [ -z "$@" ]; then ls; else z "$@" && ls; fi; } # Automatically do an ls after each zl command

# Configs
alias zshrc='nvim ~/.zshrc'                            # Edit zsh config
alias hypr='nvim ~/.config/hypr/hyprland.conf'         # Edit Hyprland config
alias grub='sudoedit /etc/default/grub'                # Edit GRUB config

# ======================
# Auto-Start compositors 
# ======================

[ "$(tty)" = "/dev/tty1" ] && exec uwsm start Hyprland          # Autostart hyprland on tty1
[ "$(tty)" = "/dev/tty2" ] && ~/.local/bin/launch-gamescope.sh  # Autostart gamescope on tty6
