{ config, lib, pkgs, upstream, ... }:
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

  wlImeShim = pkgs.runCommand "wl-ime-shim-${upstream.wl-ime-shim.version}" { } ''
    tar xzf ${upstream.wl-ime-shim.src}
    install -Dm755 wl-ime-shim $out/bin/wl-ime-shim
  '';

  # IME の候補位置のずれを防ぐため、Discord を wl-ime-shim 経由で起動する。
  # デスクトップエントリの Exec=Discord に対応するため、実行ファイルの discord と Discord の両方を置き換える。
  # --scale の値は gtk-xft-dpi=196608 による 2 倍の UI 倍率に合わせる。なお、Discord が Chromium 158 以降に更新された場合は補正が二重になるため、--scale の解除ではなく wl-ime-shim 経由の起動自体を廃止する。
  discord = pkgs.symlinkJoin {
    name = "discord-with-wl-ime-shim";
    paths = [ discordPatched ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/discord $out/bin/Discord
      makeWrapper ${wlImeShim}/bin/wl-ime-shim $out/bin/discord \
        --add-flags "--scale 2 ${discordPatched}/bin/discord"
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
