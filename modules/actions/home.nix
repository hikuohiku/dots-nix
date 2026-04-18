{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.actions.enable {
    home.packages = [ pkgs.act ];
  };
}
