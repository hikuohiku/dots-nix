{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.syncthing.enable {
    services.syncthing.enable = true;
  };
}
