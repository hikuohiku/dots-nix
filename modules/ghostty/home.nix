{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (
    config.mymodule.apps.ghostty.enable
    && pkgs.stdenv.hostPlatform.isLinux
  ) {
    home.packages = [ pkgs.ghostty ];

    xdg.configFile."ghostty/config" = {
      source = ./config;
    };
  };
}
