{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.kitty.enable {
    programs.kitty.enable = true;
  };
}
