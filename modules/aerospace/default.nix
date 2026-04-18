{ lib, ... }:
{
  options.mymodule.apps.aerospace = {
    enable = lib.mkEnableOption "AeroSpace window manager";
  };
}
