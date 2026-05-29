{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.firefox.enable {
    programs.firefox.enable = true;
    programs.firefox.configPath = ".mozilla/firefox";
  };
}
