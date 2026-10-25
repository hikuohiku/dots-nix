{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.lazygit.enable {
    homebrew.brews = [ "lazygit" ];
  };
}
