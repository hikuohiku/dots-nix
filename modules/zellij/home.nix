{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.zellij.enable {
    home.packages = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.zellij;

    home.sessionVariables = {
      ZELLIJ_AUTO_ATTACH = "true";
    };

    xdg.configFile."zellij/config.kdl" = {
      source = ./config.kdl;
    };

    programs.fish.interactiveShellInit = lib.mkOrder 200 ''
      if test "$TERM" = "alacritty"
        if not set -q ZELLIJ
          zellij
        end
      end
    '';
  };
}
