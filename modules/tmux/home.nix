{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.mymodule.apps.tmux.enable {
    home.packages = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.tmux;

    xdg.configFile."tmux/tmux.conf" = {
      source = ./tmux.conf;
    };

  };
}
