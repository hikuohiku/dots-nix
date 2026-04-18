{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.fish.enable {
    programs.fish.enable = true;
  };
}
