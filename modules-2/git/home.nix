{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.git.enable {
    home.packages = with pkgs; [
      git
      delta
      ghq
    ];

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
