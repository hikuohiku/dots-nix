{ lib, ... }:
{
  options.mymodule.apps.ml4w = {
    enable = lib.mkEnableOption "ML4W Hyprland rice (Linux only)";
  };
}
