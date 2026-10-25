{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.zellij.enable {
    homebrew.brews = [ "zellij" ];
  };
}
