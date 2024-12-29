
# Fish config

# Adds zoxide to fish
zoxide init fish | source

# Alias list 
alias yay='paru'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias pacman='sudo pacman'
alias lsh='ls -A'     
alias cls="clear"
alias kssh="kitty +kitten ssh"

# Abbreviations 
abbr -a fishconf 'open ~/.config/fish/config.fish'
abbr -a hypr 'open .config/hypr/hyprland.conf'
abbr -a grub 'sudo nvim /etc/default/grub'








# Auto start hyprland on tty1 login
if [ (tty) = "/dev/tty1" ]
    exec Hyprland
end

if test (tty) = "/dev/tty1"
    exec Hyprland
end

# No greeting 
if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting



