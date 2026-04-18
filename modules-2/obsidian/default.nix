{ lib, ... }:
{
  options.mymodule.apps.obsidian = {
    enable = lib.mkEnableOption "Obsidian";
  };
}
