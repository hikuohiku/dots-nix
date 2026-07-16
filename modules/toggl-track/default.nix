{ lib, ... }:
{
  options.mymodule.apps.toggl-track = {
    enable = lib.mkEnableOption "Toggl Track";
  };
}
