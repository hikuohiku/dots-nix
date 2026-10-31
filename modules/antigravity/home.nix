{ config, lib, ... }:
let
  cfg = config.mymodule.apps.antigravity;
in
{
  # macOS ではアプリ（brew cask）に同梱の agy を使うため、Linux 向けに公式インストーラで入れる。
  # 更新は agy 自身のバックグラウンド更新に任せる。
  config = lib.mkIf cfg.enable {
    mymodule.nativeInstall.agy = {
      binary = "agy";
      install = "curl -fsSL https://antigravity.google/cli/install.sh | bash";
    };
  };
}
