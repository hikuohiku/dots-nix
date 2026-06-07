{ lib, ... }:
{
  options.mymodule.apps.claude = {
    enable = lib.mkEnableOption "Claude Code global skills";
  };
}
