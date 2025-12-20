{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  xdg.configFile = {
    "lazygit/config.yml" = {
      source = ./config.yml;
    };
  };
}
