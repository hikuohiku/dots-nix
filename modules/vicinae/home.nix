{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  ddcutil = lib.getExe pkgs.ddcutil;

  monitorsOnHdmi1 = pkgs.writeShellScript "vicinae-monitors-on-hdmi1" ''
    # @vicinae.schemaVersion 1
    # @vicinae.title Monitors: ON / HDMI1
    # @vicinae.mode compact
    # @vicinae.keywords ["monitor", "display", "ddc", "ddc/ci", "hdmi"]

    set -euo pipefail

    # 実機では明示的な ON の後、sleep なしで HDMI1 へ切り替えられる。
    ${ddcutil} --sn=7VYRGD3 --noverify setvcp D6 0x01
    ${ddcutil} --sn=7VYRGD3 --noverify setvcp 60 0x11
    ${ddcutil} --sn=7VK4MD3 --noverify setvcp D6 0x01
    ${ddcutil} --sn=7VK4MD3 --noverify setvcp 60 0x11
    printf '%s\n' 'Monitors: ON / HDMI1'
  '';
in
{
  config = lib.optionalAttrs (lib.hasAttrByPath [ "services" "vicinae" ] options) {
    services.vicinae = lib.mkIf config.mymodule.apps.vicinae.enable {
      enable = true;
      systemd = {
        enable = true;
        environment = {
          USE_LAYER_SHELL = 1;
        };
      };
    };

    home.file = lib.mkIf config.mymodule.apps.vicinae.enable {
      ".local/share/vicinae/scripts/monitors-on-hdmi1".source = monitorsOnHdmi1;
    };
  };
}
