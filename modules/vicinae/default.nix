{ lib, ... }:
{
  options.mymodule.apps.vicinae = {
    enable = lib.mkEnableOption "vicinae launcher";
  };
}
