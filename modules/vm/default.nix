{ lib, ... }:
{
  options.mymodule.apps.vm = {
    enable = lib.mkEnableOption "Windows VM (QEMU/KVM)";
  };
}
