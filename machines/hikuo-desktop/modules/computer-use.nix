{ pkgs, upstream, ... }:
let
  # niri の画面をエージェントが操作する MCP サーバー。上流のバイナリを nix-ld で動かす。
  # インジケーターはサーバーと同じ場所に置くと見つけてもらえる。
  computerUseLinux = pkgs.runCommand "computer-use-linux-${upstream.computer-use-linux.version}" { } ''
    install -Dm755 ${upstream.computer-use-linux.src} $out/bin/computer-use-linux
    install -Dm755 ${upstream.computer-use-linux-indicator.src} $out/bin/computer-use-linux-indicator
  '';
in
{
  home.packages = [
    computerUseLinux
    pkgs.wtype # 文字入力に使う
  ];
}
