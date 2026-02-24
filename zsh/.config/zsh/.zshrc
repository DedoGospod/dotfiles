# (Interactive Shells): Sourced only for interactive shell instances.
# This is the place for terminal UI/UX: aliases, prompts, completion systems, 
# syntax highlighting, and interactive function definitions.

# ======================
# ZSH Configuration
# ======================

# Initialize ZSH completion system
zmodload zsh/complist
autoload -Uz compinit
if [[ -n "${ZSH_COMPDUMP}(#qN.m-1)" ]]; then
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

# Quality of life zsh options
setopt autocd                                    # Change directory by typing the name
setopt interactivecomments                       # Allow comments in interactive shell
setopt magicequalsubst                           # Filename expansion for arguments after =

# ======================
# Shell Initialization
# ======================

# Load plugins via loop to maintain readability and prevent exit on failure
typeset -a plugins=(
    "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
)
for plugin in $plugins; do
    [[ -r "$plugin" ]] && source "$plugin"
done

# Initialize tools only if binary exists
(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# Source functions
functions_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/functions.d"
if [[ -d "$functions_dir" ]]; then
    for file in "$functions_dir"/*(N.); do
        source "$file"
    done
fi

# File and directory searching
if (( $+commands[fzf] )); then
    # Source fzf Integration
    [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
    [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

    # Configure FD as the engine
    if (( $+commands[fd] )); then
        export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}' --bind 'enter:execute(nvim {})'"
    fi

    # Zoxide Interactive (zi)
    if (( $+commands[zoxide] )); then
        bindkey -s '^Z' 'zi\n'
    fi
fi

# ======================
# Aliases 
# ======================

# System
alias sudo='sudo '                # Always use sudo explicitly
alias rb='reboot'                 # Reboot system
alias update-grub="grub-mkconfig -o /boot/grub/grub.cfg" # Update grub

# Package Management
alias yay='paru'             # Use paru as yay alternative
alias s='yay -Ss'            # Search packages easier

# Apps
alias y='yazi'                                         # Use Yazi as a terminal file manager
alias top='btop'                                       # Modern system monitor
alias cat='bat'                                         # Cat alternative
alias cls='clear'                                      # Clear screen
alias kssh='kitty +kitten ssh'                         # SSH with kitty terminal features

# Files
alias ls='eza -1 --icons --git --group-directories-first --time-style=long-iso'
alias ll='ls -lh'           # Long listing
alias llh='ls -lhA'         # Long listing + show hidden
alias lt='ls -TL=2'         # List in tree format for 2 levels
alias lsh='ls -A'           # Show all files including hidden
alias cp='cp -i'            # Interactive copy
alias mv='mv -i'            # Interactive move
alias rm='trash -v'         # Safe delete using trash-cli
alias mkdir='mkdir -p'      # Create parent directories automatically
alias h='fc -nil 1 | grep --color=auto' # Search history for a specific terminal command
alias hist="fc -nil 1"      # Always show history with readable dates
alias du='du -h'            #
alias df='df -h'            #

# Github
alias git-reset-hard='git reset --hard origin/main'
alias gd='git diff HEAD'

# Configs
alias zshrc='nvim ~/.config/zsh/.zshrc && source ~/.config/zsh/.zshrc'  # Edit zsh config
alias zshenv='nvim ~/.zshenv'                                           # Edit zsh env file
alias zshfunc="cd $functions_dir && ls"                                 # Edit zsh functions
alias hypr='nvim ~/.config/hypr/hyprland.conf'                          # Edit Hyprland config
alias grub='sudoedit /etc/default/grub'                                 # Edit GRUB config
