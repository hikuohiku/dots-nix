{ lib, ... }:
{
  options.mymodule.apps.fish = {
    enable = lib.mkEnableOption "Fish shell";
  };
}
