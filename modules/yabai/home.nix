{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.yabai;

  moveToEmpty = pkgs.writeShellApplication {
    name = "yabai-move-to-empty";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./yabai-move-to-empty;
  };
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."yabai/yabairc" = {
      source = ./yabairc;
    };

    home.packages = [ moveToEmpty ];
  };
}
