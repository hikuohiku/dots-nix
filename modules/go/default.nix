{ lib, ... }:
{
  options.mymodule.apps.go = {
    enable = lib.mkEnableOption "Go toolchain";
  };
}
