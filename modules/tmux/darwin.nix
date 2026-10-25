{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.tmux.enable {
    homebrew.brews = [ "tmux" ];
  };
}
