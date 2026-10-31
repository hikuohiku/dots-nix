{ lib, ... }:
{
  options.mymodule.apps.antigravity = {
    enable = lib.mkEnableOption "Antigravity CLI (agy)";
  };
}
