{ config, ... }:

let
  # This helper makes the code much cleaner by reducing repetition
  linkDot = repoPath: {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${repoPath}";
  };
in {
  home.file = {
    # --- Desktop & Window Management ---
    ".config/hypr"   = linkDot "hypr/.config/hypr";
    ".config/pypr"   = linkDot "hypr/.config/pypr";
    ".config/waybar" = linkDot "waybar/.config/waybar";
    ".config/wofi"   = linkDot "wofi/.config/wofi";
    ".config/swaync" = linkDot "swaync/.config/swaync";
    
    # --- Applications & Multimedia ---
    ".config/kitty"       = linkDot "kitty/.config/kitty";
    ".config/mpv"         = linkDot "mpv/.config/mpv";
    ".config/yazi"        = linkDot "yazi/.config/yazi";
    ".config/MangoHud"    = linkDot "mangohud/.config/MangoHud";
    ".config/wayland-pipewire-idle-inhibit" = linkDot "wayland-pipewire-idle-inhibit/.config/wayland-pipewire-idle-inhibit";

    # --- Shell & Terminal Tools ---
    ".config/fastfetch" = linkDot "fastfetch/.config/fastfetch";
    ".config/starship.toml" = linkDot "starship/.config/starship.toml";
    ".config/tmux"      = linkDot "tmux/.config/tmux";
    ".config/zsh"       = linkDot "zsh/.config/zsh";
    ".zshenv"           = linkDot "zsh/.zshenv";

    # --- System & Misc ---
    ".config/autostart" = linkDot "uwsm/.config/autostart";
    ".config/uwsm"      = linkDot "uwsm/.config/uwsm";
    ".config/projects"  = linkDot "projects/Projects";
    ".config/scopebuddy" = linkDot "scopebuddy/.config/scopebuddy";
    ".config/topgrade.toml" = linkDot "topgrade/.config/topgrade.toml";
    ".config/kwalletrc" = linkDot "kwalletrc/.config/kwalletrc";
    ".config/backgrounds" = linkDot "backgrounds/.config/backgrounds";
  };
}
