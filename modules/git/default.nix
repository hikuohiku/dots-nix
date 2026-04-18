{ lib, ... }:
{
  options.mymodule.apps.git = {
    enable = lib.mkEnableOption "Git";
  };
}
