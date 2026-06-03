{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.zed.enable {
    environment.systemPackages = [ pkgs.zed-editor ];
  };
}
