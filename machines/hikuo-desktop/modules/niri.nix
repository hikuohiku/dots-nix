{ inputs', pkgs, ... }:
let
  niriPackage = inputs'.niri-flake.packages.niri-unstable;

  niriFocusOrSpawn = pkgs.writeShellApplication {
    name = "niri-focus-or-spawn";
    runtimeInputs = [
      niriPackage
      pkgs.jq
    ];
    text = ''
      if [ "$#" -lt 2 ]; then
        exit 64
      fi

      app_id="$1"
      shift

      focused_window="$(niri msg --json focused-window)"
      current_workspace_id="$(printf '%s' "$focused_window" | jq '.workspace_id // null')"
      windows="$(niri msg --json windows)"

      target_id="$(
        printf '%s' "$windows" | jq -r \
          --arg app_id "$app_id" \
          --argjson current_workspace_id "$current_workspace_id" \
          '
            map(select(.app_id == $app_id)) as $matches
            | (
                $matches
                | map(select($current_workspace_id != null and .workspace_id == $current_workspace_id))
              ) as $same_workspace
            | (if ($same_workspace | length) > 0 then $same_workspace else $matches end)
            | sort_by([(.focus_timestamp.secs // 0), (.focus_timestamp.nanos // 0)])
            | last
            | .id // empty
          '
      )"

      if [ -n "$target_id" ]; then
        niri msg action focus-window --id "$target_id"
      else
        exec "$@"
      fi
    '';
  };

  niriSpawnFocusedApp = pkgs.writeShellApplication {
    name = "niri-spawn-focused-app";
    runtimeInputs = [
      niriPackage
      pkgs.jq
    ];
    text = ''
      focused_window="$(niri msg --json focused-window)"
      focused_app_id="$(printf '%s' "$focused_window" | jq -r '.app_id // empty')"

      case "$focused_app_id" in
        Alacritty)
          exec alacritty
          ;;
        zen-beta)
          exec zen-beta
          ;;
        *)
          exit 0
          ;;
      esac
    '';
  };
in
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

  home.packages = [
    niriFocusOrSpawn
    niriSpawnFocusedApp
  ];

  programs.niri.package = niriPackage;
}
