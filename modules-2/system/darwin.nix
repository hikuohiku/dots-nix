{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.system.enable {
    system.defaults.NSGlobalDomain."com.apple.keyboard.fnState" = true;
  };
}
