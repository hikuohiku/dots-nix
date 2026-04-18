{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.zen.enable {
    homebrew.casks = [ "zen" ];
  };
}
