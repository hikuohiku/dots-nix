{ config, lib, pkgs, ... }:
let
  # macOS は App Store 版のためサンドボックス内にソケットが作られる。
  sock =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"
    else
      "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
in
{
  config = lib.mkIf config.mymodule.apps.bitwarden.enable {
    home.sessionVariables.SSH_AUTH_SOCK = sock;
    # Linux の GUI アプリは systemd のユーザー環境を引き継ぐため、そちらにも設定する。
    systemd.user.sessionVariables = lib.mkIf pkgs.stdenv.hostPlatform.isLinux { SSH_AUTH_SOCK = sock; };
  };
}
