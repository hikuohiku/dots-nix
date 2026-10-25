{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.eza.enable {
    homebrew.brews = [ "eza" ];
  };
}
