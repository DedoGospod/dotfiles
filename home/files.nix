{ config, pkgs, ... }:

let
  # Updated helper to handle both files and recursive directories
  linkDot = repoPath: {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${repoPath}";
  };

  # Helper for directories
  linkDir = repoPath: (linkDot repoPath) // { recursive = true; };
in {
  home.file = {
    # --- Directories ---
    ".config/backgrounds" = linkDir "backgrounds/.config/backgrounds";
    ".config/fastfetch"   = linkDir "fastfetch/.config/fastfetch";
    ".config/hypr"        = linkDir "hypr/.config/hypr";
    ".config/pypr"        = linkDir "hypr/.config/pypr";
    ".config/kitty"       = linkDir "kitty/.config/kitty";
    ".config/MangoHud"    = linkDir "mangohud/.config/MangoHud";
    ".config/mpv"         = linkDir "mpv/.config/mpv";
    ".config/nvim"        = linkDir "nvim/.config/nvim";
    ".config/projects"    = linkDir "projects/Projects";
    ".config/scopebuddy"  = linkDir "scopebuddy/.config/scopebuddy";
    ".config/swaync"      = linkDir "swaync/.config/swaync";
    ".config/tmux"        = linkDir "tmux/.config/tmux";
    ".config/autostart"   = linkDir "uwsm/.config/autostart";
    ".config/uwsm"        = linkDir "uwsm/.config/uwsm";
    ".config/waybar"      = linkDir "waybar/.config/waybar";
    ".config/wofi"        = linkDir "wofi/.config/wofi";
    ".config/yazi"        = linkDir "yazi/.config/yazi";
    ".config/zsh"         = linkDir "zsh/.config/zsh";
    ".config/wayland-pipewire-idle-inhibit" = linkDir "wayland-pipewire-idle-inhibit/.config/wayland-pipewire-idle-inhibit";

    # --- Individual files ---
    ".zshenv"                 = linkDot "zsh/.zshenv";
    ".config/starship.toml"   = linkDot "starship/.config/starship.toml";
    ".config/topgrade.toml"   = linkDot "topgrade/.config/topgrade.toml";
    ".config/kwalletrc"       = linkDot "kwalletrc/.config/kwalletrc";
  };
}
