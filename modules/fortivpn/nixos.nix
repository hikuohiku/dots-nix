{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.fortivpn;

  addVpnRoute = pkgs.writeShellScriptBin "_add-vpn-route" ''
    if ! ip route show | grep -q "^133.10.204.26.*ppp0"; then
      ip route add 133.10.204.26 dev ppp0
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
