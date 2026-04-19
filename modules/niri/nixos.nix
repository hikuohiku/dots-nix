{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.niri.enable {
    programs.niri.enable = true;
  };
}
