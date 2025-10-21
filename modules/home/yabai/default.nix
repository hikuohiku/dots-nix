{ pkgs, config, ... }:
{
  xdg.configFile = {
    "yabai/yabairc" = {
      source = ./yabairc;
    };
  };

  my.pkgs.yabaiScripts.move-to-empty = pkgs.writeShellApplication {
    name = "yabai-move-to-empty";
    runtimeInputs = [
      pkgs.jq
    ];
    text = builtins.readFile ./yabai-move-to-empty;
  };

  home.packages = [
    config.my.pkgs.yabaiScripts.move-to-empty
  ];
}
