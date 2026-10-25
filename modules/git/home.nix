{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.git.enable {
    home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
      git
      delta
      ghq
    ]);

    xdg.configFile = {
      "git/config" = {
        source = ./config;
      };
      "git/ignore" = {
        source = ./ignore;
      };
    };
  };
}
