{ lib, ... }:
{
  options.mymodule.apps.zellij = {
    enable = lib.mkEnableOption "Zellij terminal multiplexer";
  };
}
