{ lib, ... }:
{
  options.mymodule.apps.steam = {
    enable = lib.mkEnableOption "Steam gaming platform";
  };
}
