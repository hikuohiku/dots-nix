{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.fzf.enable {
    homebrew.brews = [ "fzf" ];
  };
}
