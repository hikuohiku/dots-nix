{ lib, ... }:
{
  options.mymodule.apps.hunk = {
    enable = lib.mkEnableOption "Hunk";
  };
}
