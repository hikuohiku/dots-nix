{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.mymodule.apps.aerospace.enable && pkgs.stdenv.hostPlatform.isDarwin) {
    home.packages = [ pkgs.aerospace ];
    xdg.configFile."aerospace/aerospace.toml".source = ./aerospace.toml;
  };
}
