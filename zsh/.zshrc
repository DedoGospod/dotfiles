# ======================
# ZSH Configuration
# ======================

# Initialize ZSH completion system
autoload -Uz compinit
if [[ -n "$ZSH_COMPDUMP(#qN.m-1)" ]]; then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -d "$ZSH_COMPDUMP"
fi

# History settings configured to be XDG-compliant
HISTSIZE=10000                                   # Number of commands kept in memory
SAVEHIST=10000                                   # Number of commands saved to HISTFILE
setopt inc_append_history                        # Save commands to history immediately
setopt share_history                             # Sync history across sessions
setopt extended_history                          # Save timestamps
setopt hist_ignore_all_dups                      # Avoid saving any duplicate commands entirely
setopt hist_ignore_space                         # If you type a command with a leading space (e.g a command containing an API key or password), Zsh should arguably not record it.

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

# Source functions
functions_file="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/functions.zsh"
[[ -f "$functions_file" ]] && source "$functions_file"

# File and directory searching
export FZF_CTRL_T_COMMAND='fd --hidden --exclude .git'                                                          # File search
export FZF_CTRL_T_OPTS=" --preview='bat --color=always --line-range :500 {}' --bind 'enter:execute(nvim {})'"   # Add preview and colors to file search
bindkey -s '^Z' 'zi\n'

# FZF key bindings and completion
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# ======================
# Aliases 
# ======================

# System
alias sudo='sudo '                # Always use sudo explicitly
alias rb='reboot'                 # Reboot system
alias update-grub="grub-mkconfig -o /boot/grub/grub.cfg" # Update grub

# Package Management
alias yay='paru'             # Use paru as yay alternative

# Apps
alias y='yazi'                                         # Use Yazi as a terminal file manager
alias top='btop'                                       # Modern system monitor
alias cls='clear'                                      # Clear screen
alias kssh='kitty +kitten ssh'                         # SSH with kitty terminal features

# Files
alias ls='eza -1 --icons --group-directories-first'
alias ll='eza -l --group-directories-first'           # Long listing
alias llh='eza -lA --group-directories-first'         # Long listing + show hidden
alias lsh='ls -A'           # Show all files including hidden
alias cp='cp -i'            # Interactive copy
alias mv='mv -i'            # Interactive move
alias rm='trash -v'         # Safe delete using trash-cli
alias mkdir='mkdir -p'      # Create parent directories automatically
alias h='fc -nil 1 | grep'  # Search history for a specific terminal command
alias hist="fc -nil 1"      # Always show history with readable dates
alias du='du -h'           
alias df='df -h'

# Github
alias git-reset-hard='git reset --hard origin/main'
alias gd='git diff HEAD'

# Configs
alias zshrc='nvim ~/.zshrc'                            # Edit zsh config
alias zshfunc='nvim ~/.config/zsh/functions.zsh'       # Edit zsh functions
alias hypr='nvim ~/.config/hypr/hyprland.conf'         # Edit Hyprland config
alias grub='sudoedit /etc/default/grub'                # Edit GRUB config
