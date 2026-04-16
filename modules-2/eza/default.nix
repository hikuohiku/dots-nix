{ lib, ... }:
{
  options.mymodule.apps.eza = {
    enable = lib.mkEnableOption "eza";
  };
}
