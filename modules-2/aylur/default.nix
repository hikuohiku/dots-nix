{ lib, ... }:
{
  options.mymodule.apps.aylur = {
    enable = lib.mkEnableOption "Aylur Hyprland rice (Linux only)";
  };
}
