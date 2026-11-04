{ lib, ... }:
{
  options.mymodule.apps.fcitx5 = {
    enable = lib.mkEnableOption "Fcitx5 candidate window theme";
  };
}
