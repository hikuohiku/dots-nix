{ lib, ... }:
{
  options.mymodule.apps.gui-tools = {
    enable = lib.mkEnableOption "desktop Linux GUI tools";
  };
}
