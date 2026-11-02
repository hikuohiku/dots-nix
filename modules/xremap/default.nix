{ lib, ... }:
{
  options.mymodule.apps.xremap = {
    enable = lib.mkEnableOption "xremap key remapper for macOS-like Cmd and Ctrl";
  };
}
