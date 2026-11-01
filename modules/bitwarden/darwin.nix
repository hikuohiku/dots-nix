{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.bitwarden.enable {
    homebrew.masApps.Bitwarden = 1352778147;
  };
}
