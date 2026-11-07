{ pkgs, ... }:
let
  niriPackage = pkgs.niri;

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

  # 配信するメインモニタ (S2725QC) を「FHD 等倍 (1920x1080 @scale1)」と「通常 (4K @scale2)」でトグルする。
  # コネクタ名は配線で変わるので、モデル名から引く。
  # Sunshine の software エンコードは 4K キャプチャが重いので、配信時だけ FHD 等倍に落とす。
  # niri msg output は一時変更 (niri 再起動でリセット) なので nix の恒久設定は変えない。
  # DMS は UI 全体を読み込むまで壁紙を描かない。ログイン直後の空白を埋めるため、
  # DMS と同じ画像を先に swaybg で描く（DMS の壁紙が上に重なる）。
  niriEarlyWallpaper = pkgs.writeShellApplication {
    name = "niri-early-wallpaper";
    runtimeInputs = [
      pkgs.swaybg
      pkgs.jq
    ];
    text = ''
      img=$(jq -r '.wallpaperPath // empty' "$HOME/.local/state/DankMaterialShell/session.json")
      [ -f "$img" ] || exit 0
      exec swaybg -m fill -i "$img"
    '';
  };

  # Zen Browser の拡張機能ウィンドウとピクチャーインピクチャーのみを floating に維持し、それ以外をタイルへ戻す。
  # 起動直後は全ウィンドウのタイトルが "Zen Browser" で区別できないため、niri.kdl でいったん全ウィンドウを floating で開く。
  # 判定は "Zen Browser" を除いた最初のタイトルで行い、通常ウィンドウのタブで拡張機能ページを開いた場合の誤判定を防ぐ。
  # 通常ウィンドウはタイトルが "Zen Browser" のまま変わらないことがあるため、1 秒経過しても同じタイトルの場合はタイルへ戻す。
  niriFloatExtensionWindows = pkgs.writeShellApplication {
    name = "niri-float-extension-windows";
    runtimeInputs = [
      niriPackage
      pkgs.jq
    ];
    text = ''
      declare -A seen timer
      niri msg --json event-stream \
        | jq --unbuffered -r '
            .WindowOpenedOrChanged.window // empty
            | select(.app_id == "zen-beta")
            | "\(.id)\t\(.title)"
          ' \
        | while IFS=$'\t' read -r id title; do
            [ -z "''${seen[$id]:-}" ] || continue
            case "$title" in
              "Zen Browser")
                [ -z "''${timer[$id]:-}" ] || continue
                timer[$id]=1
                (
                  sleep 1
                  now="$(niri msg --json windows | jq -r --argjson id "$id" '.[] | select(.id == $id) | .title')"
                  if [ "$now" = "Zen Browser" ]; then
                    niri msg action move-window-to-tiling --id "$id"
                  fi
                ) &
                ;;
              "拡張機能: "*|"ピクチャーインピクチャー")
                seen[$id]=1
                niri msg action move-window-to-floating --id "$id" || true
                ;;
              *)
                seen[$id]=1
                niri msg action move-window-to-tiling --id "$id" || true
                ;;
            esac
          done
    '';
  };

  niriToggleStreamDisplay = pkgs.writeShellApplication {
    name = "niri-toggle-stream-display";
    runtimeInputs = [
      niriPackage
      pkgs.jq
      pkgs.libnotify
    ];
    text = ''
      out="$(niri msg --json outputs \
        | jq -r 'to_entries[] | select(.value.model == "DELL S2725QC") | .key')"
      width="$(niri msg --json outputs \
        | jq -r --arg o "$out" '.[$o].modes[.[$o].current_mode].width')"

      if [ "$width" = "3840" ]; then
        # 4K -> 配信用 FHD 等倍
        niri msg output "$out" mode 1920x1080@60.000
        niri msg output "$out" scale 1
        notify-send -t 2000 "Display" "$out: 1920x1080 @1 (stream)" || true
      else
        # 復帰: 4K @2
        niri msg output "$out" mode 3840x2160@120.000
        niri msg output "$out" scale 2
        notify-send -t 2000 "Display" "$out: 3840x2160 @2 (normal)" || true
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
        com.mitchellh.ghostty)
          exec ghostty
          ;;
        code)
          exec code --enable-wayland-ime --new-window
          ;;
        Slack)
          exec slack
          ;;
        zen-beta)
          exec zen-beta
          ;;
        org.gnome.Nautilus)
          exec nautilus --new-window
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
  # モニタ配置はログイン画面（host.nix の greeter 設定）と共有する。
  programs.niri.config = builtins.readFile ./niri-outputs.kdl + builtins.readFile ./niri.kdl;

  # config 文字列が settings 描画を上書きするのでレンダリングには使われないが、dms の
  # border-fix が config.programs.niri.settings.layout.border.enable を参照するため、
  # settings を null にせず最小限だけ定義しておく (niri.kdl 側も border off で整合)。
  programs.niri.settings.layout.border.enable = false;

  programs.dank-material-shell.niri = {
    enableSpawn = false; # DMS は systemd で起動する（home.nix）
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
    niriEarlyWallpaper
    niriFloatExtensionWindows
    niriFocusOrSpawn
    niriSpawnFocusedApp
    niriToggleStreamDisplay
  ];

  programs.niri.package = niriPackage;
}
