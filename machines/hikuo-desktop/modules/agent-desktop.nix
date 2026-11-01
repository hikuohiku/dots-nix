{ pkgs, ... }:
let
  # エージェントに操作させる入れ子の sway。niri の中の 1 ウィンドウとして動く。
  swayConfig = pkgs.writeText "agent-desktop-sway.conf" ''
    # MCP サーバーがこのセッションを指せるよう、接続先を書き出す。
    exec sh -c 'printf "WAYLAND_DISPLAY=%s\nSWAYSOCK=%s\n" "$WAYLAND_DISPLAY" "$SWAYSOCK" > "$XDG_RUNTIME_DIR/agent-desktop.env"'
    exec alacritty
    bindsym Mod4+Return exec alacritty
    bindsym Mod4+Shift+q kill
  '';

  agentDesktop = pkgs.writeShellApplication {
    name = "agent-desktop";
    runtimeInputs = [ pkgs.sway ];
    # NVIDIA のプロプライエタリドライバだと sway は --unsupported-gpu 無しでは起動しない。
    text = ''
      WLR_BACKENDS=wayland exec sway --unsupported-gpu -c ${swayConfig}
    '';
  };

  # computer-use-sway は Python パッケージで PyPI に無いため、uvx で GitHub の最新を使う。
  # 操作は sway IPC / wtype / grim なので入れ子の sway に閉じるが、drag だけは /dev/uinput に
  # 直接書き、OS 全体（niri 側）へ入力が漏れる。uinput を /dev/null で塞いで起動する。
  computerUse = pkgs.writeShellApplication {
    name = "computer-use-agent-desktop";
    runtimeInputs = [
      pkgs.sway
      pkgs.grim
      pkgs.wtype
      pkgs.wl-clipboard
      pkgs.uv
      pkgs.bubblewrap
    ];
    text = ''
      env_file="$XDG_RUNTIME_DIR/agent-desktop.env"
      if [ -f "$env_file" ]; then
        set -a
        # shellcheck disable=SC1090
        . "$env_file"
        set +a
      fi
      if [ ! -S "''${SWAYSOCK:-}" ]; then
        echo "agent-desktop が起動していません" >&2
        exit 1
      fi
      exec bwrap --dev-bind / / --ro-bind /dev/null /dev/uinput -- \
        uvx --from git+https://github.com/blackopsrepl/computer-use-sway computer-use-sway "$@"
    '';
  };
in
{
  home.packages = [
    agentDesktop
    computerUse
  ];
}
