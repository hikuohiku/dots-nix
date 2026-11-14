{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.agent-browser.enable {
    home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.agent-browser ];
  };
}
