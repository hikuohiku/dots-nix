{ lib, ... }:
{
  options.mymodule.apps.firefox = {
    enable = lib.mkEnableOption "Firefox";
  };
}
