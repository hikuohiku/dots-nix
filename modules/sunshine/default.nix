{ lib, ... }:
{
  options.mymodule.apps.sunshine = {
    enable = lib.mkEnableOption "Sunshine desktop/game stream host for Moonlight";
  };
}
