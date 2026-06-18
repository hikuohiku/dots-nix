{ lib, ... }:
{
  options.mymodule.apps.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth (BlueZ, DMS 連携 / 起動時オフ)";
  };
}
