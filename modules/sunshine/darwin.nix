{ config, lib, ... }:
{
  # macOS では Sunshine を brew の LizardByte tap から bottle で導入し、launchd ユーザーエージェントで常駐させる。設定ファイルは home.nix が配置する。
  # 初回起動時に「画面収録」と「アクセシビリティ」の許可が必要。
  config = lib.mkIf config.mymodule.apps.sunshine.enable {
    homebrew.taps = [ "lizardbyte/homebrew" ];
    homebrew.brews = [ "lizardbyte/homebrew/sunshine" ];

    launchd.user.agents.sunshine.serviceConfig = {
      # 設定パスを指定せずに起動し、既定の ~/.config/sunshine/sunshine.conf を読み込む。
      ProgramArguments = [ "/opt/homebrew/opt/sunshine/bin/sunshine" ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}
