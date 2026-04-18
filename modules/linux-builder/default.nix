{ lib, ... }:
{
  options.mymodule.apps.linux-builder = {
    enable = lib.mkEnableOption "x86_64 Linux builder VM";
  };
}
