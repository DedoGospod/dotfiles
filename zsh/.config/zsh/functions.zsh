#!/usr/bin/env zsh

### Custom Zsh Functions ###

# Automatically do an ls after each zl command
zl() { if [ -z "$@" ]; then ls; else z "$@" && ls; fi; } # Automatically do an ls after each zl command

# nv works for root and user files
nv() {
  if [ -z "$1" ]; then command nvim; return; fi
  if [ -f "$1" ] && [ ! -O "$1" ]; then echo "Using sudoedit for root file: $1"; command sudoedit "$@"; else command nvim "$@"; fi
}
