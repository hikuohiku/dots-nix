{ lib, ... }:
{
  options.mymodule.apps.touchid = {
    enable = lib.mkEnableOption "Touch ID for sudo";
  };
}
