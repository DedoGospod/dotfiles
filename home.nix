{ config, pkgs, ... }:

{
    imports = [
        ./modules/neovim.nix
        ./modules/hyprland.nix
    ];

    home.packages = with pkgs; [
        # Core desktop
        hypridle
        hyprlock
        hyprpaper
        hyprpolkitagent
        #hyprland-guiutils  
        hyprutils
        waybar
        #swaync
        dbus
        hyprsunset

        # Shell & CLI
        kitty
        zsh
        zsh-completions
        zsh-syntax-highlighting
        zsh-autosuggestions
        starship
        fzf
        zoxide
        fd
        tmux
        bat
        eza
        ripgrep
        trash-cli
    ];


  programs.git.enable = true;
  home.stateVersion = "25.05";
  programs.bash = {
    enable = true;
  };

  # Dotfiles

  # Symlink Directories
  home.file.".config/backgrounds".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/backgrounds/.config/backgrounds";
  home.file.".config/fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/fastfetch/.config/fastfetch";
  home.file.".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/hypr/.config/hypr";
  home.file.".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/hypr/.config/pypr";
  home.file.".config/kitty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/kitty/.config/kitty";
  home.file.".config/MangoHud".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/mangohud/.config/MangoHud";
  home.file.".config/mpv".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/mpv/.config/mpv";
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/nvim/.config/nvim";
  home.file.".config/projects".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/projects/Projects";
  home.file.".config/scopebuddy".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/scopebuddy/.config/scopebuddy";
  home.file.".config/swaync".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/swaync/.config/swaync";
  home.file.".config/tmux".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/tmux/.config/tmux";
  home.file.".config/autostart".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/uwsm/.config/autostart";
  home.file.".config/uwsm".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/uwsm/.config/uwsm";

  home.file.".config/waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/waybar/.config/waybar";
  home.file.".config/wayland-pipewire-idle-inhibit".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/wayland-pipewire-idle-inhibit/.config/wayland-pipewire-idle-inhibit";
  home.file.".config/wofi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/wofi/.config/wofi";
  home.file.".config/yazi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/yazi/.config/yazi";
  home.file.".config/zsh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/zsh/.config/zsh";

  # Symlink individual files
  home.file.".zshenv".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/zsh/.zshenv";
  home.file.".config/starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/starship/.config/starship.toml";
  home.file.".config/topgrade.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/topgrade/.config/topgrade.toml";
  home.file.".config/kwalletrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/kwalletrc/.config/kwalletrc";
}
