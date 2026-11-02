{ config, lib, pkgs, ... }:
let
  # Wayland で生じる黒い外枠を防ぐため、core.asar を書き換えて hasShadow:false を適用する。
  # Electron がフレームレスウィンドウに付与する影用の余白が Discord では黒枠になるが、設定が存在しないため直接置換する。
  # asar のバイト数を変えずに置換し、対象箇所が見つからない場合は警告を出力して未修正のままビルドを通す。
  discord = pkgs.discord.override {
    unwrappedDiscord = pkgs.discord.unwrappedDiscord.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        core=$(find -L $out/opt/Discord/modules/discord_desktop_core -name core.asar)
        if LC_ALL=C grep -aq 'transparent:!1,frame:!1' "$core"; then
          chmod u+w "$core"
          sed -i 's/transparent:!1,frame:!1/hasShadow:!1,  frame:!1/g' "$core"
        else
          echo "warning: discord: hasShadow patch target not found" >&2
        fi
      '';
    });
  };
in
{
  config = lib.mkIf (config.mymodule.apps.gui-tools.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = with pkgs; [
      pavucontrol # PulseAudio GUI
      nautilus # file manager
      mission-center
      google-chrome

      # social
      slack
      teams-for-linux
      discord

      # media player
      vlc

      # flatpak https://wiki.nixos.org/wiki/Flatpak
      flatpak
      gnome-software
    ];
  };
}
