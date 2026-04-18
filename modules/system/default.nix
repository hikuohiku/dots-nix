{ lib, ... }:
{
  options.mymodule.apps.system = {
    enable = lib.mkEnableOption "system defaults";
  };
}
