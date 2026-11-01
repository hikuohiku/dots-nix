{ pkgs, ... }:
{
  # ELECOM 2MP Webcam の IR カメラで、Bitwarden のロック解除だけを顔認証にする。
  # 解除は polkit 経由で行われる。PAM の単位では polkit-1 を指定するしかないため、
  # 他の polkit ダイアログも顔で通る。
  services.howdy = {
    enable = true;
    control = "sufficient";
    # /dev/videoN の番号は接続順で変わる。by-id は通常カメラと IR カメラで名前が重なるため、
    # by-path を使う。差し込むポートを変えたらここも直す。
    settings.video.device_path = "/dev/v4l/by-path/pci-0000:00:14.0-usb-0:6.1.1:1.2-video-index0";
  };
  security.pam.howdy.enable = false;
  security.pam.services.polkit-1.howdy.enable = true;

  # polkit の action 定義（com.bitwarden.Bitwarden.policy）をシステムに置くため、system 側に入れる。
  environment.systemPackages = [ pkgs.bitwarden-desktop ];
}
