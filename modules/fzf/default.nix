{ lib, ... }:
{
  options.mymodule.apps.fzf = {
    enable = lib.mkEnableOption "fzf";
  };
}
