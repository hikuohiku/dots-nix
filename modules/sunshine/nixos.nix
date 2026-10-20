{ config, lib, pkgs, upstream, ... }:
let
  # NVENC 付きの上流 AppImage を取得して使う（modules/upstream で版を追従）。nixpkgs 版は
  # cudaSupport=true にすると cache に無く CUDA 込みのソースビルドになるため。設定は home-manager で配置する
  # 生の sunshine.conf（modules/sunshine/sunshine.conf）を既定パスから読む。
  sunshine = pkgs.appimageTools.wrapType2 {
    pname = "sunshine";
    inherit (upstream.sunshine) version src;
  };
in
{
  config = lib.mkIf config.mymodule.apps.sunshine.enable {
    environment.systemPackages = [ sunshine ];

    # マウス入力に /dev/uinput が要る。
    hardware.uinput.enable = true;

    # Moonlight からの自動検出用。
    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    # 既定ポート 47989 基準。
    networking.firewall = {
      allowedTCPPorts = [ 47984 47989 47990 48010 ];
      allowedUDPPorts = [ 47998 47999 48000 48002 48010 ];
    };

    # キャプチャは wlr (Wayland screencopy) で動くため capSysAdmin(KMS 用) は不要。
    systemd.user.services.sunshine = {
      description = "Self-hosted game stream host for Moonlight";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      startLimitIntervalSec = 500;
      startLimitBurst = 5;
      serviceConfig = {
        ExecStart = lib.getExe sunshine;
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
