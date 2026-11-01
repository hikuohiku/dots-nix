{ pkgs, ... }:
{
  # ELECOM 2MP Webcam の IR カメラで、polkit（Bitwarden のロック解除を含む）と sudo を顔認証にする。
  services.howdy = {
    enable = true;
    control = "sufficient";
    settings.video.device_path = "/dev/ir-camera";
  };
  # /dev/videoN の番号は接続順で変わり、by-id は通常カメラと IR カメラで名前が重なる。
  # IR 側（名前に Face を含む）のキャプチャノードに固定名を付ける。
  services.udev.extraRules = ''
    SUBSYSTEM=="video4linux", ATTRS{idVendor}=="056e", ATTRS{idProduct}=="701e", ATTR{name}=="*Face*", ATTR{index}=="0", SYMLINK+="ir-camera"
  '';
  security.pam.howdy.enable = false;
  security.pam.services.polkit-1.howdy.enable = true;
  security.pam.services.sudo.howdy.enable = true;
  # polkit の PAM はサンドボックス化された agent helper で動き、既定ではカメラが見えない。
  systemd.services."polkit-agent-helper@".serviceConfig = {
    PrivateDevices = false;
    DeviceAllow = [ "char-video4linux rw" ];
  };

  # polkit の action 定義（com.bitwarden.Bitwarden.policy）をシステムに置くため、system 側に入れる。
  environment.systemPackages = [ pkgs.bitwarden-desktop ];
}
