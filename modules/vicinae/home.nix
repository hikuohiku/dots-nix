{ config, lib, options, ... }:
{
  config = lib.optionalAttrs
    (lib.hasAttrByPath [ "services" "vicinae" ] options)
    {
      services.vicinae = lib.mkIf config.mymodule.apps.vicinae.enable {
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
