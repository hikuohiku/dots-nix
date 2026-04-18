{ lib, ... }:
{
  options.mymodule.apps.cli-tools = {
    enable = lib.mkEnableOption "CLI tool collection";
  };
}
