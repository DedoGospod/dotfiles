{ config, ... }:

let
  linkDot = repoPath: {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${repoPath}";
  };
in {

  # Dotfiles
  home.file = {
    # Directories
    ".config/backgrounds"                   = linkDot "backgrounds/.config/backgrounds";
    ".config/fastfetch"                     = linkDot "fastfetch/.config/fastfetch";
    ".config/hypr"                          = linkDot "hypr/.config/hypr";
    ".config/pypr"                          = linkDot "hypr/.config/pypr";
    ".config/kitty"                         = linkDot "kitty/.config/kitty";
    ".config/MangoHud"                      = linkDot "mangohud/.config/MangoHud";
    ".config/mpv"                           = linkDot "mpv/.config/mpv";
    ".config/nvim"                          = linkDot "nvim/.config/nvim";
    ".config/projects"                      = linkDot "projects/Projects";
    ".config/scopebuddy"                    = linkDot "scopebuddy/.config/scopebuddy";
    ".config/swaync"                        = linkDot "swaync/.config/swaync";
    ".config/tmux"                          = linkDot "tmux/.config/tmux";
    ".config/autostart"                     = linkDot "uwsm/.config/autostart";
    ".config/uwsm"                          = linkDot "uwsm/.config/uwsm";
    ".config/waybar"                        = linkDot "waybar/.config/waybar";
    ".config/wofi"                          = linkDot "wofi/.config/wofi";
    ".config/yazi"                          = linkDot "yazi/.config/yazi";
    ".config/zsh"                           = linkDot "zsh/.config/zsh";
    ".config/wayland-pipewire-idle-inhibit" = linkDot "wayland-pipewire-idle-inhibit/.config/wayland-pipewire-idle-inhibit";

    # Individual files
    ".zshenv"                               = linkDot "zsh/.zshenv";
    ".config/starship.toml"                 = linkDot "starship/.config/starship.toml";
    ".config/topgrade.toml"                 = linkDot "topgrade/.config/topgrade.toml";
    ".config/kwalletrc"                     = linkDot "kwalletrc/.config/kwalletrc";
  };
}
