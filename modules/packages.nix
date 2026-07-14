{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    git
    zsh-completions
    zsh-syntax-highlighting
    zsh-autosuggestions
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

programs.git = {
  enable = true;
  package = pkgs.gitFull;

  config = {
    user = {
      name = "dylan";
      email = "dylanlazarov2002@protonmail.com";
    };
    credential = {
      helper = "libsecret";
    };
  };
};

}
