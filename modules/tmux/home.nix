{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.mymodule.apps.tmux.enable {
    home.packages = [ pkgs.tmux ];
  };
}
