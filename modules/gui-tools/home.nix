{ config, lib, pkgs, ... }:
let
  # Wayland で生じる黒い外枠を防ぐため、core.asar を書き換えて hasShadow:false を適用する。
  # Electron がフレームレスウィンドウに付与する影用の余白が Discord では黒枠になるが、設定が存在しないため直接置換する。
  # asar のバイト数を変えずに置換し、対象箇所が見つからない場合は警告を出力して未修正のままビルドを通す。
  discordPatched = pkgs.discord.override {
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

  discordImeProxy = pkgs.rustPlatform.buildRustPackage {
    pname = "discord-ime-proxy";
    version = "0.1.0";
    src = ./discord-ime-proxy;
    cargoLock.lockFile = ./discord-ime-proxy/Cargo.lock;
  };

  # IME の候補位置のずれを防ぐため、Discord を discord-ime-proxy 経由で起動する。
  # デスクトップエントリで Exec=Discord が指定されているため、実行ファイルの discord と Discord の両方を置き換える。
  discord = pkgs.symlinkJoin {
    name = "discord-with-ime-proxy";
    paths = [ discordPatched ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/discord $out/bin/Discord
      makeWrapper ${discordImeProxy}/bin/discord-ime-proxy $out/bin/discord \
        --add-flags ${discordPatched}/bin/discord
      ln -s discord $out/bin/Discord
    '';
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
