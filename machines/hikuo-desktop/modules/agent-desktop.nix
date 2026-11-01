{ pkgs, ... }:
let
  # エージェントに操作させる画面。画面に出さないヘッドレスの sway として動かす。
  swayConfig = pkgs.writeText "agent-desktop-sway.conf" ''
    output HEADLESS-1 resolution 1280x800
    # MCP サーバーがこのセッションを指せるよう、接続先を書き出す。
    exec sh -c 'printf "WAYLAND_DISPLAY=%s\nSWAYSOCK=%s\n" "$WAYLAND_DISPLAY" "$SWAYSOCK" > "$XDG_RUNTIME_DIR/agent-desktop.env"'
    exec alacritty
    bindsym Mod4+Return exec alacritty
    bindsym Mod4+Shift+q kill
  '';

  # computer-use-sway は Python パッケージで PyPI に無いため、uvx で GitHub の最新を使う。
  # 操作は sway IPC / wtype / grim なのでこの sway に閉じるが、drag だけは /dev/uinput に
  # 直接書き、OS 全体（niri 側）へ入力が漏れる。uinput を /dev/null で塞いで起動する。
  # wtype は起動のたびに仮想キーボードを作り直し、受け手がキー配列を読む前の最初のキーが落ちる。
  # 先頭で少し待たせる。
  wtype = pkgs.writeShellScriptBin "wtype" ''
    exec ${pkgs.wtype}/bin/wtype -s 50 "$@"
  '';

  computerUse = pkgs.writeShellApplication {
    name = "computer-use-agent-desktop";
    runtimeInputs = [
      pkgs.sway
      pkgs.grim
      wtype
      pkgs.wl-clipboard
      pkgs.uv
      pkgs.bubblewrap
      pkgs.systemd
    ];
    text = ''
      env_file="$XDG_RUNTIME_DIR/agent-desktop.env"
      systemctl --user start agent-desktop.service
      for _ in $(seq 50); do
        if [ -f "$env_file" ]; then
          set -a
          # shellcheck disable=SC1090
          . "$env_file"
          set +a
          [ -S "''${SWAYSOCK:-}" ] && break
        fi
        sleep 0.2
      done
      if [ ! -S "''${SWAYSOCK:-}" ]; then
        echo "agent-desktop を起動できませんでした" >&2
        exit 1
      fi
      exec bwrap --dev-bind / / --ro-bind /dev/null /dev/uinput -- \
        uvx --from git+https://github.com/blackopsrepl/computer-use-sway computer-use-sway "$@"
    '';
  };
in
{
  home.packages = [
    computerUse
    # 中で動くシェル（fish の done プラグイン）が SWAYSOCK を見て swaymsg を呼ぶ。
    pkgs.sway
  ];

  # MCP サーバーが必要になったときに起動する（ログイン時には起動しない）。
  systemd.user.services.agent-desktop = {
    Unit.Description = "Headless sway for agent computer use";
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/rm -f %t/agent-desktop.env";
      ExecStart = "${pkgs.sway}/bin/sway --unsupported-gpu -c ${swayConfig}";
      Environment = [
        "WLR_BACKENDS=headless"
        "WLR_RENDERER=pixman"
        "WLR_LIBINPUT_NO_DEVICES=1"
        # niri の WAYLAND_DISPLAY を引き継ぐと入れ子として起動してしまう。
        "WAYLAND_DISPLAY="
      ];
    };
  };
}
