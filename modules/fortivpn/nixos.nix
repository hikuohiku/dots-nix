{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.fortivpn;
in
{
  config = lib.mkIf cfg.enable {
    systemd.services.openfortivpn = {
      description = "openfortivpn VPN client";
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.openfortivpn}/bin/openfortivpn -c /etc/openfortivpn/config";
        Type = "simple";
        Restart = "no";
      };
      wantedBy = [ ];
    };

    environment.etc."ppp/ip-up" = {
      mode = "0755";
      text = ''
        #!/bin/sh
        if [ "$1" = "ppp-tmuvpn" ]; then
          ${pkgs.iproute2}/bin/ip link set "$1" mtu 1300
        fi
      '';
    };

    security.sudo.extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl start openfortivpn
      %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl stop openfortivpn
    '';
  };
}
