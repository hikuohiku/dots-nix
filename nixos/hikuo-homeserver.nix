{ pkgs, ... }:
{
  # vaultwarden
  # tailscale serveでtailnet内に公開
  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    config = {
      WEB_VAULT_ENABLED = true;
      SINGUPS_ALLOWED = false;
      SIGNUPS_VERIFY = true;
      DOMAIN = "https://hikuo-homeserver.tailae6c2.ts.net";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
    environmentFile = "/etc/nixos/secret/bitwarden.env";
  };

  systemd.services.tailscale-serve = {
    description = "Tailscale Service Serving vaultwarden";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve 8222";
      Restart = "on-failure";
      User = "root";
      Group = "root";
    };
  };
}

