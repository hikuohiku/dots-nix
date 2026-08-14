{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  ddcutil = lib.getExe pkgs.ddcutil;

  # 現在値が目標と一致していれば書き込まない。同じ値でも setvcp は再同期を
  # 起こしうるため、既に望む状態なら触らない。読めなかった場合は書き込む。
  # 消灯中でも D6/60 は実測どおりの値を返す（実機で確認済み）。
  setvcpIfNeeded = ''
    setvcp_if_needed() {
      sn=$1
      feature=$2
      want=$3
      cur=$(${ddcutil} --sn="$sn" --brief getvcp "$feature" 2>/dev/null | awk '$1 == "VCP" { print $4 }') || cur=""
      if [ "$cur" = "x$want" ]; then
        return 0
      fi
      ${ddcutil} --sn="$sn" --noverify setvcp "$feature" "0x$want"
    }
  '';

  monitorsOnHdmi1 = pkgs.writeShellScript "vicinae-monitors-on-hdmi1" ''
    # @vicinae.schemaVersion 1
    # @vicinae.title Monitors: ON / HDMI1
    # @vicinae.mode compact
    # @vicinae.keywords ["monitor", "display", "ddc", "ddc/ci", "hdmi"]

    set -euo pipefail

    ${setvcpIfNeeded}

    # 実機では明示的な ON の後、sleep なしで HDMI1 へ切り替えられる。
    setvcp_if_needed 7VYRGD3 D6 01
    setvcp_if_needed 7VYRGD3 60 11
    setvcp_if_needed 7VK4MD3 D6 01
    setvcp_if_needed 7VK4MD3 60 11
    printf '%s\n' 'Monitors: ON / HDMI1'
  '';

  monitorsOff = pkgs.writeShellScript "vicinae-monitors-off" ''
    # @vicinae.schemaVersion 1
    # @vicinae.title Monitors: OFF
    # @vicinae.mode compact
    # @vicinae.keywords ["monitor", "display", "ddc", "ddc/ci", "off", "power"]

    set -euo pipefail

    ${setvcpIfNeeded}

    # D6 0x04 (DPM Off) は DDC で復帰できる。0x05 は復帰に物理操作が要る。
    setvcp_if_needed 7VYRGD3 D6 04
    setvcp_if_needed 7VK4MD3 D6 04
    printf '%s\n' 'Monitors: OFF'
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
      ".local/share/vicinae/scripts/monitors-off".source = monitorsOff;
    };
  };
}
