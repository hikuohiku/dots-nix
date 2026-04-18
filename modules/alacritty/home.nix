{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.alacritty.enable (lib.mkMerge [
    {
      xdg.configFile."alacritty/alacritty.toml" = {
        source = ./alacritty.toml;
      };
    }
    (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      home.packages = [ pkgs.alacritty ];
    })
  ]);
}
