{ lib, ... }:
{
  options.mymodule.apps.yabai = {
    enable = lib.mkEnableOption "Yabai tiling window manager";
  };
}
