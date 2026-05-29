{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.steam.enable {
    hardware.graphics.enable32Bit = true;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      extest.enable = false;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    programs.gamemode.enable = true;

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    environment.systemPackages = [
      pkgs.protonup-qt
      pkgs.xwayland-satellite
      pkgs.protontricks
    ];

    # nixpkgs の bubblewrap は setuid モード非対応のため上書き
    # virtualisation.containers.enable が setuid=true で追加するものと競合する
    security.wrappers.bwrap = lib.mkForce {
      owner = "root";
      group = "root";
      source = "${pkgs.bubblewrap}/bin/bwrap";
      setuid = false;
      capabilities = "";
    };
  };
}
