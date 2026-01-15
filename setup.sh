#!/usr/bin/env bash

# Ensure gum is installed
if ! command -v gum &> /dev/null; then
    echo "gum is not installed. please download it first."
    exit 1
fi

# Define path clearly
SCRIPT_DIR="$HOME/dotfiles/setup-scripts"

SCRIPTS=(
    "setup-cachyos-repos.sh"
    "setup-dotfiles.sh"
    "setup-firewall.sh"
    "setup-gaming.sh"
    "setup-applications.sh"
    "setup-nvidia.sh"
    "setup-virtualization.sh"
    "setup-wol.sh"
    "setup-github.sh"
)

# Ensure all scripts are executable
if [ -d "$SCRIPT_DIR" ]; then
    cd "$SCRIPT_DIR" || exit
    chmod u+x "${SCRIPTS[@]}" 2>/dev/null
else
    echo "Directory $SCRIPT_DIR not found!"
    exit 1
fi

# Helper function
run_script() {
    local script_file=$1
    if [ -f "$script_file" ]; then
        gum style --foreground 212 --border double --align center --width 40 "Running: $(basename "$script_file")"
        bash "$script_file"
    else
        gum style --foreground 196 "󰚌 Error: $script_file not found!"
    fi
}

while true; do
  choice=$(gum choose \
    "Cachyos repo setup" \
    "Dotfile setup" \
    "Firewall setup" \
    "Gaming setup" \
    "Application setup" \
    "Nvidia setup" \
    "Virtualization setup" \
    "Wakeonlan setup" \
    "Github setup" \

    "exit")

  case "$choice" in
    "Cachyos repo setup")
      run_script "$SCRIPT_DIR/setup-cachyos-repos.sh"
      ;;

    "Dotfile setup")
      run_script "$SCRIPT_DIR/setup-dotfiles.sh"
      ;;

    "Firewall setup")
      run_script "$SCRIPT_DIR/setup-firewall.sh"
      ;;

    "Gaming setup")
      run_script "$SCRIPT_DIR/setup-gaming.sh"
      ;;

    "Application setup")
      run_script "$SCRIPT_DIR/setup-applications.sh"
      ;;

    "Nvidia setup")
      run_script "$SCRIPT_DIR/setup-nvidia.sh"
      ;;

    "Virtualization setup")
      run_script "$SCRIPT_DIR/setup-virtualization.sh"
      ;;

    "Wakeonlan setup")
      run_script "$SCRIPT_DIR/setup-wol.sh"
      ;;

    "Github setup")
      run_script "$SCRIPT_DIR/setup-github.sh"
      ;;

    "exit")
      gum style --foreground 240 "exiting..."
      exit 0
      ;;
      
    *)
      exit 0
      ;;
  esac
  
  echo ""
  gum style --foreground 240 "󱊷 press any key to return to menu..."
  read -r -n 1
  clear
done
