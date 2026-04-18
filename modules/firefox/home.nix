{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.firefox.enable {
    programs.firefox.enable = true;
  };
}
