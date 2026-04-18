{ lib, ... }:
{
  options.mymodule.apps.skhd = {
    enable = lib.mkEnableOption "skhd hotkey daemon";
  };
}
