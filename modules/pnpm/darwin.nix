{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.pnpm.enable {
    homebrew.brews = [ "pnpm" ];
  };
}
