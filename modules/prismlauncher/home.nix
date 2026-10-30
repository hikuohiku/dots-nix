{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.mymodule.apps.prismlauncher.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [ pkgs.prismlauncher ];
  };
}
