{ config, lib, pkgs, upstream, ... }:
let
  # 上流のバイナリをそのまま使う。デスクトップ版はシステムの Qt を前提にしているので、
  # nixpkgs の Qt へつなぎ直す。
  codexbar = pkgs.stdenv.mkDerivation {
    pname = "codexbar";
    inherit (upstream.codexbar-desktop) version;
    src = upstream.codexbar-desktop.src;

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.qt6.wrapQtAppsHook
    ];
    buildInputs = [
      pkgs.curl
      pkgs.qt6.qtbase
      pkgs.qt6.qtdeclarative
      pkgs.qt6.qtsvg
      pkgs.qt6.qtwayland
      pkgs.sqlite
      pkgs.stdenv.cc.cc.lib
    ];

    dontBuild = true;
    dontStrip = true;
    dontWrapQtApps = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 bin/codexbar-linux $out/bin/codexbar-linux
      install -Dm644 Integrations/Linux/icon.svg $out/share/icons/hicolor/scalable/apps/codexbar.svg
      install -Dm644 /dev/stdin $out/share/applications/com.steipete.CodexBar.desktop <<DESKTOP
      [Desktop Entry]
      Type=Application
      Name=CodexBar
      Comment=AI usage, accounts and local spending
      Exec=$out/bin/codexbar-linux --usage
      Icon=codexbar
      Terminal=false
      Categories=Utility;Development;
      StartupWMClass=com.steipete.CodexBar
      DESKTOP

      # CLI は同じ場所のリソースを読むので、まとめて置いてリンクする。
      mkdir -p $out/lib/codexbar-cli
      tar -xzf ${upstream.codexbar-cli.src} -C $out/lib/codexbar-cli
      ln -s $out/lib/codexbar-cli/codexbar $out/bin/codexbar

      runHook postInstall
    '';

    postFixup = ''
      wrapQtApp $out/bin/codexbar-linux --prefix PATH : $out/bin
    '';
  };
in
{
  config = lib.mkIf (config.mymodule.apps.codexbar.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [ codexbar ];
  };
}
