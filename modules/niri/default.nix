{ lib, ... }:
{
  options.mymodule.apps.niri = {
    enable = lib.mkEnableOption "niri scrollable-tiling Wayland compositor";
  };
}
