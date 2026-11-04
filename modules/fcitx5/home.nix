{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.fcitx5.enable {
    xdg.configFile."fcitx5/conf/classicui.conf".source = ./classicui.conf;
    xdg.dataFile."fcitx5/themes/sequoia".source = ./themes/sequoia;
  };
}
