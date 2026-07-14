{ config, ... }:
{
  # Base XDG Directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # Centralized Environment Variables
  home.sessionVariables = {
    # Application Paths
    CARGO_HOME      = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME     = "${config.xdg.dataHome}/rustup";
    GNUPGHOME       = "${config.xdg.dataHome}/gnupg";
    GOPATH          = "${config.xdg.dataHome}/go";
    PYTHONHISTORY   = "${config.xdg.stateHome}/python/history";
    DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
    NUGET_PACKAGES  = "${config.xdg.dataHome}/nuget/packages";
    PARALLEL_HOME   = "${config.xdg.configHome}/parallel";

    # NPM Config
    NPM_CONFIG_USERCONFIG  = "${config.xdg.configHome}/npm/npmrc";
    NPM_CONFIG_INIT_MODULE = "${config.xdg.configHome}/npm/config/npm-init.js";
    NPM_CONFIG_CACHE       = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_TMP         = "${config.xdg.cacheHome}/npm/tmp";

    # Graphics/Misc
    GTK2_RC_FILES               = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    CUDA_CACHE_PATH             = "${config.xdg.cacheHome}/nv";
    __GL_SHADER_DISK_CACHE_PATH = "${config.xdg.cacheHome}/nv";
    ANDROID_USER_HOME           = "${config.xdg.dataHome}/android";
  };

  # Path Management
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.xdg.dataHome}/cargo/bin"
    "${config.xdg.dataHome}/go/bin"
  ];
}
