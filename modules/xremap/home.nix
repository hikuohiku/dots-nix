{ config, lib, pkgs, upstream, ... }:
let
  xremap = pkgs.stdenvNoCC.mkDerivation {
    pname = "xremap";
    inherit (upstream.xremap) version src;
    nativeBuildInputs = [ pkgs.unzip ];
    sourceRoot = ".";
    installPhase = "install -Dm755 xremap $out/bin/xremap";
  };
in
{
  config = lib.mkIf config.mymodule.apps.xremap.enable {
    xdg.configFile."xremap/config.yml".source = ./config.yml;

    systemd.user.services.xremap = {
      Unit = {
        Description = "xremap key remapper";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        X-Restart-Triggers = [ "${./config.yml}" ];
      };
      Service = {
        ExecStart = "${xremap}/bin/xremap --device HHKB-Hybrid --watch=device %h/.config/xremap/config.yml";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
