{ pkgs, ... }:
let
  addVpnRoute = pkgs.writeShellScriptBin "_add-vpn-route" ''
    # Check if route already exists (idempotent)
    if ! netstat -rn | grep -q "^133.10.204.26.*ppp0"; then
      /sbin/route add -host 133.10.204.26 -interface ppp0
    fi
  '';
in
{
  homebrew.casks = [
    "xbar"
  ];

  security.sudo.extraConfig = ''
    %admin ALL=(ALL) NOPASSWD: /bin/launchctl start org.nixos.openfortivpn
    %admin ALL=(ALL) NOPASSWD: /bin/launchctl stop org.nixos.openfortivpn
    %admin ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/_add-vpn-route
  '';

  environment.systemPackages = [ addVpnRoute ];

  launchd.daemons.openfortivpn = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.openfortivpn}/bin/openfortivpn"
        "-c"
        "/Users/hikuo/Documents/.fortivpn-config"
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
}
