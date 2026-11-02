{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.xremap.enable {
    hardware.uinput.enable = true;
    # キー入力の読み取りは input グループを避け、HHKB だけログイン中のユーザーへ許可する。
    # uaccess は 73-seat-late.rules より前に付ける必要があるので、extraRules (99-) は使わない。
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "xremap-udev-rules";
        text = ''
          SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="*HHKB-Hybrid*", TAG+="uaccess"
        '';
        destination = "/etc/udev/rules.d/70-xremap.rules";
      })
    ];
  };
}
