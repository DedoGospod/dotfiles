{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    #npm
    nodejs
    unzip
    #clang
    go
    shellcheck
    zig
    luarocks
    dotnet-sdk
    cmake
    gcc
    #tree-sitter-cli
    imagemagick
    cargo
    nil
    #nixfmt
  ];
}
