{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.glide.enable {
    homebrew.casks = [ "glide" ];
  };
}
