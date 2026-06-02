{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.fortivpn;

  addVpnRoute = pkgs.writeShellScriptBin "_add-vpn-route" ''
    for i in $(seq 1 30); do
      ${pkgs.iproute2}/bin/ip link show ppp0 > /dev/null 2>&1 && break
      sleep 1
    done
    if ! ${pkgs.iproute2}/bin/ip route show | grep -q "^133.10.204.26.*ppp0"; then
      ${pkgs.iproute2}/bin/ip route add 133.10.204.26 dev ppp0
    fi
  '';
in
{
  config = lib.mkIf cfg.enable {
    systemd.services.openfortivpn = {
      description = "openfortivpn VPN client";
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.openfortivpn}/bin/openfortivpn -c /etc/openfortivpn/config";
        ExecStartPost = "${addVpnRoute}/bin/_add-vpn-route";
        Type = "simple";
        Restart = "no";
      };
      wantedBy = [ ];
    };

    security.sudo.extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl start openfortivpn
      %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl stop openfortivpn
    '';

    environment.systemPackages = [ addVpnRoute ];
  };
}
