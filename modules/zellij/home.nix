{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.zellij.enable {
    home.packages = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.zellij;

    xdg.configFile."zellij/config.kdl" = {
      source = ./config.kdl;
    };
  };
}
