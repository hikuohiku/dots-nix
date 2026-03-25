{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.fortivpn;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  scriptContent =
    builtins.replaceStrings [ "@openfortivpn@" ] [ "${pkgs.openfortivpn}/bin/openfortivpn" ]
      (builtins.readFile ./hikuo-openfortivpn.sh);
  scriptPkg = pkgs.writeShellScriptBin "hikuo-openfortivpn.sh" scriptContent;
in
{
  config = lib.mkIf (cfg.enable && isDarwin) {
    home.file = {
      "Library/Application Support/xbar/plugins/hikuo-openfortivpn.sh" = {
        source = "${scriptPkg}/bin/hikuo-openfortivpn.sh";
      };
      "proxy.pac" = {
        source = ./proxy.pac;
      };
    };
  };
}
