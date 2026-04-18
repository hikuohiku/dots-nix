{ lib, ... }:
{
  options.mymodule.apps.alacritty = {
    enable = lib.mkEnableOption "Alacritty terminal emulator";
  };
}
