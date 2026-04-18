{ lib, ... }:
{
  options.mymodule.apps.fonts = {
    enable = lib.mkEnableOption "font packages";
  };
}
