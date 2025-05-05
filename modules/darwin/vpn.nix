{ pkgs, ... }:
{
  launchd.daemons."openfortivpn" = {
    command = "${pkgs.openfortivpn}/bin/openfortivpn -c /Users/hikuo/.vpn/config";
    serviceConfig = {
      Disabled = true;
      StandardErrorPath = "/tmp/openfortivpn.error.log";
      StandardOutPath = "/tmp/openfortivpn.log";
    };
  };
}
