{ lib, ... }:
{
  options.mymodule.apps.kitty = {
    enable = lib.mkEnableOption "Kitty terminal";
  };
}
