{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.core.enable {
    homebrew.brews = [ "rust" "uv" ];
  };
}
