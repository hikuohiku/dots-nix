{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.mymodule.apps.obsidian.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [ pkgs.obsidian ];
  };
}
