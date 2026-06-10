{ inputs', ... }:
{
  # niri 設定は raw KDL (./niri.kdl) で管理する。
  # nix 式 (programs.niri.settings) だと niri-flake のスキーマ更新待ちで niri 新機能
  # (background-effect/blur 等) の対応が遅れるため。
  # programs.niri.config に文字列を渡すと settings 描画を完全にバイパスし、dms が hm.kdl へ
  # リネームするファイルの中身がこの KDL になる。niri-flake が niri validate で検証する。
  programs.niri.config = builtins.readFile ./niri.kdl;

  # config 文字列が settings 描画を上書きするのでレンダリングには使われないが、dms の
  # border-fix が config.programs.niri.settings.layout.border.enable を参照するため、
  # settings を null にせず最小限だけ定義しておく (niri.kdl 側も border off で整合)。
  programs.niri.settings.layout.border.enable = false;

  programs.dank-material-shell.niri = {
    enableSpawn = false; # spawn-at-startup は niri.kdl に直書きしたため不要
    includes = {
      enable = true;
      filesToInclude = [
        "alttab"
        "colors"
        "cursor"
        "layout"
        "windowrules"
        "wpblur"
      ];
    };
  };

  programs.niri.package = inputs'.niri-flake.packages.niri-unstable;
}
