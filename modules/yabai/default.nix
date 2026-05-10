{ lib, ... }:
{
  options.mymodule.apps.yabai = {
    enable = lib.mkEnableOption "Yabai tiling window manager";
    enableService = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to create launchd services for yabai.";
    };
  };
}
