{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.ghostty.enable {
    # macOS は cask で入れる。設定ファイルはどちらの OS でも同じものを使う。
    home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.ghostty ];

    xdg.configFile."ghostty/config" = {
      source = ./config;
    };
  };
}
