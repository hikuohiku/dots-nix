{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.touchid.enable {
    security.pam.services.sudo_local = {
      enable = true;
      touchIdAuth = true;
      reattach = true;
    };
  };
}
