{ config, lib, pkgs, upstream, ... }:
let
  cfg = config.mymodule.apps.herdr;

  # コミュニティ製の GUI クライアント（macOS は brew の cask）。上流の tarball をそのまま置き、
  # NixOS では nix-ld で動かす。ランチャーで公式アプリ（Herdr）と区別できるよう名前を変える。
  herdrGpui = pkgs.runCommand "herdr-gpui-${upstream.herdr-gpui.version}" { } ''
    mkdir -p $out
    tar -xzf ${upstream.herdr-gpui.src} -C $out --strip-components=1
    substituteInPlace $out/share/applications/so.pen.herdr-gpui.desktop \
      --replace-fail "Name=Herdr" "Name=Herdr UI"
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Linux は nixpkgs から、macOS は brew(./darwin.nix) で導入する。
      # macOS 側で nixpkgs 版も入れると brew と二重導入になるため isLinux で絞る
      # (machines の apps.nix は darwin と home-manager の両スコープに import される)。
      home.packages = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.herdr;
    }
    (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      # 公式のネイティブアプリ。TUI（上の herdr）とは別のプログラムで、サーバー（herdr-core）が
      # 無ければ一緒に入れ、以後の herdr-core の更新はアプリが行う。
      mymodule.nativeInstall.herdr-app = {
        binary = "herdr-app";
        install = "curl -fsSL https://releases.herdr.dev/app/install.sh | sh";
      };

      home.packages = [ herdrGpui ];
    })
  ]);
}
