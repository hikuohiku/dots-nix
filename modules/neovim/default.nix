{ lib, ... }:
{
  options.mymodule.apps.neovim = {
    enable = lib.mkEnableOption "Neovim";
  };
}
