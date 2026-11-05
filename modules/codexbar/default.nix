{ lib, ... }:
{
  options.mymodule.apps.codexbar = {
    enable = lib.mkEnableOption "CodexBar";
  };
}
