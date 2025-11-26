# My dotfiles for system configuration 
Run install script for automatic setup (arch linux)
- cd dotfiles
- chmod +x install-script.sh
- ./install-script-archlinux.sh 

Run the systemd services setup script (any systemd distro)
- cd dotfiles
- chmod +x ./services-systemd.sh
- ./services-systemd.sh

# For manual setup install GNU stow
Arch:
- sudo pacman -S stow

Debian: 
- sudo apt install stow
  
Fedora:
- sudo dnf install stow

# Stow instructions 
- cd dotfiles
- ls (to list avaliable packages)
- stow <directoryName> (user files)
- sudo stow -t / <directoryName> (system files)
