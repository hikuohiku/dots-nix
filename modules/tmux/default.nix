{ lib, ... }:
{
  options.mymodule.apps.tmux = {
    enable = lib.mkEnableOption "tmux terminal multiplexer";
  };
}
