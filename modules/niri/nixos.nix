{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.mymodule.apps.niri.enable {
    programs.niri.enable = true;
    # GlobalShortcuts portal (xdg-desktop-portal-gnome) の動作に必要（niri wiki 参照）。
    environment.systemPackages = [ pkgs.gnome-control-center ];
  };
}
