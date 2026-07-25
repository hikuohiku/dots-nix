{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.hunk.enable {
    xdg.configFile."hunk/config.toml".text = ''
      hunk_headers = false
    '';

    programs.fish.functions.hunk = ''
      set -lx GIT_CONFIG_COUNT 1
      set -lx GIT_CONFIG_KEY_0 diff.context
      set -lx GIT_CONFIG_VALUE_0 20
      command hunk $argv
    '';
  };
}
