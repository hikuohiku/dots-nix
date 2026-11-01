{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.bitwarden.enable {
    # polkit の action 定義（com.bitwarden.Bitwarden.policy）をシステムに置くため、system 側に入れる。
    environment.systemPackages = [ pkgs.bitwarden-desktop ];
    # gnome-keyring の SSH エージェントが SSH_AUTH_SOCK を上書きしないよう止める。
    services.gnome.gcr-ssh-agent.enable = false;
  };
}
