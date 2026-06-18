{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.sunshine.enable {
    # 生の設定ファイルを decided-config として配置する（services.sunshine.settings は使わない）。
    # サービスは設定パス無しで起動し、この既定パスを読む。
    xdg.configFile."sunshine/sunshine.conf".source = ./sunshine.conf;
  };
}
