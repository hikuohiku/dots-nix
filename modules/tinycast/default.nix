{ lib, ... }:
{
  options.mymodule.apps.tinycast = {
    enable = lib.mkEnableOption "Tinycast launcher";
  };
}
