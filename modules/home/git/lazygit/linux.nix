{
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    xdg.configFile = {
      "lazygit/config.yml" = {
        source = ./lazygit-config.yml;
      };
    };
  };
}
