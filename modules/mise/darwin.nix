{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.mise.enable {
    homebrew.brews = [ "mise" ];
  };
}
