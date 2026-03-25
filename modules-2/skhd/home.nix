{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.skhd;

  yabaiMoveToEmpty = pkgs.writeShellApplication {
    name = "yabai-move-to-empty";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ../yabai/yabai-move-to-empty;
  };
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."skhd/skhdrc" = {
      source = pkgs.replaceVars ./skhdrc {
        yabaiMoveToEmpty = "${yabaiMoveToEmpty}/bin/yabai-move-to-empty";
      };
    };
  };
}
