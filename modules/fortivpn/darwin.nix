{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mymodule.apps.fortivpn;
in
{
  config = lib.mkIf cfg.enable {
    homebrew.casks = [ "xbar" ];

    security.sudo.extraConfig = ''
      %admin ALL=(ALL) NOPASSWD: /bin/launchctl start org.nixos.openfortivpn
      %admin ALL=(ALL) NOPASSWD: /bin/launchctl stop org.nixos.openfortivpn
    '';

    # pppd link-up フック。macOS の system pppd は --no-routes でも ppp 上に
    # デフォルトルートを張ってしまう (全トラフィックが VPN を通る) ため、接続時に
    # MTU 設定・スプリットルート追加と、そのデフォルトルートの除去を自動で行う。
    # macOS pppd は ifname 非対応で interface 名は ppp0 のままなので、本接続の識別は
    # openfortivpn の --pppd-ipparam=tmuvpn で渡されるタグ ($6) で行う。
    environment.etc."ppp/ip-up".source = pkgs.writeShellScript "forti-ip-up" ''
      # pppd args: $1=interface $2=tty $3=speed $4=local-ip $5=remote-ip $6=ipparam
      [ "$6" = "tmuvpn" ] || exit 0

      # MTU を NixOS 実装に合わせる (macOS デフォルトは 1354)
      /sbin/ifconfig "$1" mtu 1300
      # VPN 対象のみトンネル経由
      /sbin/route -n add -net 133.10.0.0/16 -interface "$1" 2>/dev/null || true
      # pppd が tunnel 上に張る interface-scoped なデフォルトのみ除去する。
      # -ifscope で対象を ppp に限定するため、グローバル (Wi-Fi/テザリング) の
      # デフォルトには絶対に触れない。マッチしなければ単に no-op で安全。
      /sbin/route -n delete -ifscope "$1" default 2>/dev/null || true
    '';

    launchd.daemons.openfortivpn = {
      serviceConfig = {
        ProgramArguments = [
          "${pkgs.openfortivpn}/bin/openfortivpn"
          "-c"
          "/Users/hikuo/.vpn/config"
          "--no-routes"
          "--pppd-ipparam=tmuvpn"
        ];
        KeepAlive = false;
        RunAtLoad = false;
        StandardOutPath = "/tmp/openfortivpn.log";
        StandardErrorPath = "/tmp/openfortivpn.err";
      };
    };

    launchd.user.agents.ssh-socks = {
      serviceConfig = {
        ProgramArguments = [
          "/usr/bin/ssh"
          "-N"
          "-D"
          "127.0.0.1:1080"
          "hiro@lab-peridot"
          "-o"
          "ServerAliveInterval=30"
          "-o"
          "ServerAliveCountMax=3"
          "-o"
          "ExitOnForwardFailure=yes"
        ];
        KeepAlive = false;
        RunAtLoad = false;
        StandardOutPath = "/tmp/ssh-socks.log";
        StandardErrorPath = "/tmp/ssh-socks.err";
      };
    };
  };
}
