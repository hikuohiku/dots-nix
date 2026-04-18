{ lib, ... }:
{
  options.mymodule.apps.ghostty = {
    enable = lib.mkEnableOption "Ghostty terminal";
  };
}
