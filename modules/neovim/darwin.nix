{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.neovim.enable {
    homebrew.brews = [ "neovim" ];
  };
}
