{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.eza.enable {
    programs.eza = {
      enable = true;
      enableFishIntegration = false;
    };
  };
}
