{ pkgs, ... }:

{
  # 1. packages
  home.packages = with pkgs; [
    kdeconnect-kde
    valent
  ];

}
