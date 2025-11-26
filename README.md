# My dotfiles for system configuration 

Run install script for automatic setup (arch linux)
- cd dotfiles
- chmod +x install-script.sh
- ./install-script.sh

# For manual setup install stow

Arch:
- sudo pacman -S stow

Debian: 
- sudo apt install stow
  
Fedora:
- sudo dnf install stow

# Stow instructions 
- cd dotfiles
- ls (to list avaliable packages)
- stow <package name> (user files)
- sudo stow -t / <package name> (system files)
