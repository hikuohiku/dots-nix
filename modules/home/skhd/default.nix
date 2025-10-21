{
  config,
  pkgs,
  ...
}:
let
  hasYabaiScript = config.my.pkgs ? yabaiScripts.move-to-empty;
  yabaiMoveToEmptyPathStr =
    if hasYabaiScript then
      "${config.my.pkgs.yabaiScripts.move-to-empty}/bin/yabai-move-to-empty"
    else
      "yabai-move-to-empty";

in
{
  xdg.configFile = {
    "skhd/skhdrc" = {
      source = pkgs.replaceVars ./skhdrc {
        yabaiMoveToEmpty = yabaiMoveToEmptyPathStr;
      };
    };
  };
}
