{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.alacritty.enable {
    homebrew.casks = [ "alacritty" ];
  };
}
