#!/usr/bin/env zsh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
usage()   { echo -e "${CYAN}[Usage]${NC} $1"; } 
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Custom Snapper manual snapshot function
snapper-create() {
    if [[ -z "$1" ]]; then
        error "Please provide a description."
        usage "snapper-create <description>"
        return 1
    fi

    sudo snapper -c root create --description "$1" --cleanup-algorithm number
    success "Snapshot created: $1"
}

# Extract any common compressed file types
extract() {
  if [[ $# -ne 1 ]]; then
    error "Please provide a file"
    usage "extract <file_name>" >&2
    return 1
  fi

  if [[ -f "$1" ]]; then
    case "${1:l}" in # :l converts to lowercase for case-insensitive matching
      *.tar.bz2|*.tbz2) tar xjf "$1"    ;;
      *.tar.gz|*.tgz)   tar xzf "$1"    ;;
      *.bz2)            bunzip2 "$1"    ;;
      *.rar)            unrar x "$1"    ;;
      *.gz)             gunzip "$1"     ;;
      *.tar)            tar xf "$1"     ;;
      *.zip)            unzip "$1"      ;;
      *.Z)              uncompress "$1" ;;
      *.7z)             7z x "$1"       ;;
      *)                error "'$1' cannot be extracted via extract()" >&2
                        return 1 ;;
    esac
  else
    error "'$1' is not a valid file" >&2
    return 1
  fi
}

# Open tldr manual in neovim
tldr() {
    if [[ -n "$1" ]]; then
        command tldr "$@" | nvim -R -c "set ft=help" -
    else
        error "Please provide a command"
        usage "tldr <package>"
        return 1
    fi
}
