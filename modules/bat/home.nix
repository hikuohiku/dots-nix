{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.bat.enable {
    programs.bat.enable = true;
  };
}
