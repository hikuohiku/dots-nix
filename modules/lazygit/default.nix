{ lib, ... }:
{
  options.mymodule.apps.lazygit = {
    enable = lib.mkEnableOption "Lazygit";
  };
}
