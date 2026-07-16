{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.mymodule.apps.tmux.enable {
    home.packages = with pkgs; [
      go
      tmux
    ];

    xdg.configFile."tmux/tmux.conf" = {
      source = ./tmux.conf;
    };

    xdg.configFile."tabby/config.yaml" = {
      source = ./tabby.yaml;
    };
  };
}
