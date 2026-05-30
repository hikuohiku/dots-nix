{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.vicinae.enable {
    services.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        environment = {
          USE_LAYER_SHELL = 1;
        };
      };
    };
  };
}
