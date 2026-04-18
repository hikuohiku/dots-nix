{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.lazygit;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.lazygit.enable = true;
    }
    (lib.mkIf isDarwin {
      home.file."Library/Application Support/lazygit/config.yml" = {
        source = ./config.yml;
      };
    })
    (lib.mkIf isLinux {
      xdg.configFile."lazygit/config.yml" = {
        source = ./config.yml;
      };
    })
  ]);
}
