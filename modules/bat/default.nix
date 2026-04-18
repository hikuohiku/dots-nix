{ lib, ... }:
{
  options.mymodule.apps.bat = {
    enable = lib.mkEnableOption "bat";
  };
}
