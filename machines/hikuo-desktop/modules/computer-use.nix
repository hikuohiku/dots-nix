{ pkgs, upstream, ... }:
let
  # niri の org.gnome.Shell.Screenshot は出力が 1 つのときしか撮影できず、それを使うポータルも
  # 複数モニタでは撮影できない。computer-use-linux が呼ぶ gnome-screenshot を grim に差し替える。
  gnomeScreenshot = pkgs.writeShellScriptBin "gnome-screenshot" ''
    # -f 以外は有無の確認（--version）で呼ばれる。
    [ "$1" = "-f" ] || exit 0
    exec ${pkgs.grim}/bin/grim "$2"
  '';

  # niri の画面をエージェントが操作する MCP サーバー。上流のバイナリを nix-ld で動かす。
  computerUseLinux = pkgs.writeShellScriptBin "computer-use-linux" ''
    export COMPUTER_USE_LINUX_SCREENSHOT_BACKEND=gnome-screenshot
    export COMPUTER_USE_LINUX_INDICATOR_BIN=${indicator}
    export PATH=${pkgs.lib.makeBinPath [ gnomeScreenshot pkgs.wtype pkgs.ydotool ]}:$PATH
    systemctl --user start ydotoold.service
    exec ${server} "$@"
  '';

  executable =
    name: src:
    pkgs.runCommand name { } ''
      install -Dm755 ${src} $out
    '';
  server = executable "computer-use-linux-${upstream.computer-use-linux.version}" upstream.computer-use-linux.src;
  indicator = executable "computer-use-linux-indicator-${upstream.computer-use-linux-indicator.version}" upstream.computer-use-linux-indicator.src;
in
{
  home.packages = [ computerUseLinux ];

  # キー操作の送信に使う。niri の RemoteDesktop ポータルはキーボードを扱えない。
  # 必要になったときにサーバーの起動スクリプトから起動する。
  systemd.user.services.ydotoold = {
    Unit.Description = "ydotool daemon for computer-use-linux";
    Service.ExecStart = "${pkgs.ydotool}/bin/ydotoold --socket-path=%t/.ydotool_socket --socket-perm=0600";
  };
}
