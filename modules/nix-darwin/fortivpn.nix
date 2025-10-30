{ pkgs, ... }:
{
  homebrew.casks = [
    "xbar"
  ];

  security.sudo.extraConfig = ''
    %admin ALL=(ALL) NOPASSWD: ${pkgs.openfortivpn}/bin/openfortivpn
    %admin ALL=(ALL) NOPASSWD: /usr/bin/killall -2 openfortivpn
  '';
}
