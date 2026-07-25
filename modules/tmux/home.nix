{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.mymodule.apps.tmux.enable {
    home.packages = with pkgs; [
      tmux
    ];

    xdg.configFile."tmux/tmux.conf" = {
      source = ./tmux.conf;
    };

  };
}
