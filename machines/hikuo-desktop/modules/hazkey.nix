{
  inputs,
  pkgs,
  upstream,
  ...
}:
let
  # 上流のビルド済みバイナリを NixOS 向けにパッチして使う。ソースビルドには Swift が必要なため。
  hazkey = pkgs.stdenv.mkDerivation {
    pname = "fcitx5-hazkey";
    inherit (upstream.hazkey) version src;

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      makeWrapper
      qt6.wrapQtAppsHook
    ];
    buildInputs = with pkgs; [
      fcitx5
      qt6.qtbase
      qt6.qtwayland
      stdenv.cc.cc.lib
      vulkan-loader
    ];

    dontStrip = true;
    dontWrapQtApps = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/lib
      cp -r share $out/share
      cp -r lib/x86_64-linux-gnu/fcitx5 $out/lib/fcitx5
      cp -r lib/x86_64-linux-gnu/hazkey $out/lib/hazkey

      # 辞書とバックエンドの既定パスは /usr に固定されているので環境変数で渡す。
      # サーバーは二重起動の判定に `pgrep -x hazkey-server` を使うため、プロセス名が
      # 変わる wrapProgram ではなく makeWrapper で包む。
      makeWrapper $out/lib/hazkey/hazkey-server $out/bin/hazkey-server \
        --set-default HAZKEY_DICTIONARY $out/share/hazkey/Dictionary \
        --set-default GGML_BACKEND_DIR $out/lib/hazkey/libllama/backends/ \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.procps ]}

      mv $out/lib/hazkey/hazkey-settings $out/bin/hazkey-settings
      wrapQtApp $out/bin/hazkey-settings
      runHook postInstall
    '';
  };

  # 標準辞書に無い語を補うため、UT 辞書をユーザー辞書の形式へ変換する。
  hazkey-ut-dict =
    pkgs.runCommand "hazkey-ut-dict"
      {
        nativeBuildInputs = [ pkgs.python3 ];
      }
      ''
        python3 ${./hazkey-ut-dict.py} ${hazkey}/share/hazkey/Dictionary/louds/charID.chid $out \
          ${inputs.mozcdic-ut-jawiki}/mozcdic-ut-jawiki.txt.bz2 \
          ${inputs.mozcdic-ut-neologd}/mozcdic-ut-neologd.txt.bz2 \
          ${inputs.mozcdic-ut-skk-jisyo}/mozcdic-ut-skk-jisyo.txt.bz2 \
          ${inputs.mozcdic-ut-sudachidict}/mozcdic-ut-sudachidict.txt.bz2
      '';
in
{
  i18n.inputMethod.fcitx5.addons = [ hazkey ];

  # アドオンと設定画面は hazkey-server を PATH から起動する。
  environment.systemPackages = [ hazkey ];

  # hazkey-settings がこのファイルへ保存するので、書き込める out-of-store symlink にする。
  home-manager.users.hikuo =
    { config, ... }:
    {
      xdg.configFile."hazkey/config.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ghq/github.com/hikuohiku/dots-nix/machines/hikuo-desktop/modules/hazkey-config.json";

      # 変換エンジンはユーザー辞書をこのディレクトリから読む。
      xdg.cacheFile."hazkey/shared".source = hazkey-ut-dict;
    };
}
