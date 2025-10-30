{ pkgs, ... }:
let
  scriptContent =
    builtins.replaceStrings [ "@openfortivpn@" ] [ "${pkgs.openfortivpn}/bin/openfortivpn" ]
      (builtins.readFile ./hikuo-openfortivpn.sh);
in
{
  home.file = {
    "Library/Application Support/xbar/hikuo-openfortivpn.sh" = {
      source = pkgs.writeShellApplication {
        name = "hikuo-openfortivpn.sh";
        runtimeInputs = with pkgs; [ openfortivpn ];
        text = scriptContent;
      };
    };
  };
}
