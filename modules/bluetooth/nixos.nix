{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      # 起動時は未電源（自動再接続しない）。使うときだけ DMS でオン
      powerOnBoot = false;
      settings = {
        # bluetoothd が起動時/再起動後にコントローラを自動 power-on しない
        Policy.AutoEnable = false;
        # Battery1 を有効化しデバイスのバッテリー残量を取得（DMS で表示）
        General.Experimental = true;
      };
    };

    # DMS の BatteryService(Quickshell.Services.UPower) が BT デバイスの
    # バッテリーを拾うため
    services.upower.enable = true;
  };
}
