{ pkgs, ... }:
{
  homebrew.casks = [
    "xbar"
  ];

  homebrew.brews = [
    "autossh"
  ];

  security.sudo.extraConfig = ''
    %admin ALL=(ALL) NOPASSWD: ${pkgs.openfortivpn}/bin/openfortivpn
    %admin ALL=(ALL) NOPASSWD: /usr/bin/killall -2 openfortivpn
  '';

  launchd.user.agents.autossh-socks = {
    serviceConfig = {
      ProgramArguments = [
        "/opt/homebrew/bin/autossh"
        "-M"
        "0"
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
      KeepAlive = true;
      RunAtLoad = false;
      StandardOutPath = "/tmp/autossh-socks.log";
      StandardErrorPath = "/tmp/autossh-socks.err";
    };
  };
}
