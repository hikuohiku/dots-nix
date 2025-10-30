{ pkgs, ... }:
let
  scriptContent =
    builtins.replaceStrings [ "@openfortivpn@" ] [ "${pkgs.openfortivpn}/bin/openfortivpn" ]
      (builtins.readFile ./hikuo-openfortivpn.sh);
  scriptPkg = pkgs.writeShellScriptBin "hikuo-openfortivpn.sh" scriptContent;
in
{
  home.file = {
    "Library/Application Support/xbar/plugins/hikuo-openfortivpn.sh" = {
      source = "${scriptPkg}/bin/hikuo-openfortivpn.sh";
    };
  };
}
