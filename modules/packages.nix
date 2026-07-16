{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    brave
    vim
    git
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    ubuntu-classic
    liberation_ttf
    dejavu_fonts
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

}
