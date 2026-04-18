{ lib, ... }:
{
  options.mymodule.apps.zen = {
    enable = lib.mkEnableOption "Zen Browser";
  };
}
