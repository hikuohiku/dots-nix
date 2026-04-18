{ lib, ... }:
{
  options.mymodule.apps.karabiner = {
    enable = lib.mkEnableOption "Karabiner-Elements";
  };
}
