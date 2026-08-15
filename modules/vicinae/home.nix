{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  ddcutil = lib.getExe pkgs.ddcutil;

  monitorSerials = [
    "7VYRGD3"
    "7VK4MD3"
  ];

  ddcHelpers = ''
    # 現在値が目標と一致していれば書き込まない。同じ値でも setvcp は再同期を
    # 起こしうるため、既に望む状態なら触らない。読めなかった場合は書き込む。
    # 消灯中でも D6/60 は実測どおりの値を返す（実機で確認済み）。
    setvcp_if_needed() {
      sn=$1
      feature=$2
      want=$3
      # getvcp --brief は x1b のように小文字で返すので want も小文字で渡す。
      cur=$(${ddcutil} --sn="$sn" --brief getvcp "$feature" 2>/dev/null | awk '$1 == "VCP" { print $4 }') || cur=""
      if [ "$cur" = "x$want" ]; then
        return 0
      fi
      ${ddcutil} --sn="$sn" --noverify setvcp "$feature" "0x$want"
    }

    # 引数の関数をシリアル番号付きでモニタごとに並列実行し、全部の完了を待つ。
    # 1 台でも失敗したら 1 を返す（wait は引数なしだと失敗を握り潰すため個別に待つ）。
    for_each_monitor() {
      pids=""
      for sn in ${lib.concatStringsSep " " monitorSerials}; do
        "$@" "$sn" &
        pids="$pids $!"
      done

      rc=0
      for pid in $pids; do
        wait "$pid" || rc=1
      done
      return "$rc"
    }
  '';

  # 点灯させたうえで入力を切り替えるコマンドを作る。
  monitorsOnInput =
    {
      name,
      label,
      input,
      keywords,
    }:
    pkgs.writeShellScript "vicinae-monitors-on-${name}" ''
      # @vicinae.schemaVersion 1
      # @vicinae.title Monitors: ON / ${label}
      # @vicinae.mode compact
      # @vicinae.keywords ${
        builtins.toJSON (
          [
            "monitor"
            "display"
            "ddc"
            "ddc/ci"
          ]
          ++ keywords
        )
      }

      set -euo pipefail

      ${ddcHelpers}

      # 実機では明示的な ON の後、sleep なしで入力を切り替えられる。
      monitor_on_input() {
        setvcp_if_needed "$1" D6 01
        setvcp_if_needed "$1" 60 ${input}
      }

      for_each_monitor monitor_on_input
      printf '%s\n' 'Monitors: ON / ${label}'
    '';

  monitorsOnHdmi1 = monitorsOnInput {
    name = "hdmi1";
    label = "HDMI1";
    input = "11";
    keywords = [ "hdmi" ];
  };

  # 0x1b は capabilities では未知値として出るが、この機種の 3 番目の入力＝USB-C。
  monitorsOnUsbc = monitorsOnInput {
    name = "usbc";
    label = "USB-C";
    input = "1b";
    keywords = [
      "usb-c"
      "usbc"
      "type-c"
    ];
  };

  monitorsOff = pkgs.writeShellScript "vicinae-monitors-off" ''
    # @vicinae.schemaVersion 1
    # @vicinae.title Monitors: OFF
    # @vicinae.mode compact
    # @vicinae.keywords ["monitor", "display", "ddc", "ddc/ci", "off", "power"]

    set -euo pipefail

    ${ddcHelpers}

    # D6 0x04 (DPM Off) は DDC で復帰できる。0x05 は復帰に物理操作が要る。
    monitor_off() {
      setvcp_if_needed "$1" D6 04
    }

    for_each_monitor monitor_off
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
      ".local/share/vicinae/scripts/monitors-on-usbc".source = monitorsOnUsbc;
      ".local/share/vicinae/scripts/monitors-off".source = monitorsOff;
    };
  };
}
