{ lib, ... }:
{
  options.mymodule.apps.zed = {
    enable = lib.mkEnableOption "Zed editor";
  };
}
