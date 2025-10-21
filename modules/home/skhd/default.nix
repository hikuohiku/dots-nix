{ config, pkgs, ... }:
{
  xdg.configFile = {
    "skhd/skhdrc" = {
      source = pkgs.replaceVars ./skhdrc {
        yabaiMoveToEmpty = "${config.my.pkgs.yabaiScripts.move-to-empty}/bin/yabai-move-to-empty";
      };
    };
  };
}
