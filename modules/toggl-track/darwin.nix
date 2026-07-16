{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.toggl-track.enable {
    homebrew.masApps = {
      "Toggl Track: Hours & Time Log" = 1291898086;
    };
  };
}
