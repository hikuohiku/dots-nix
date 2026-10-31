{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  # ddcutil を含めた monitors-ddc スクリプトのパッケージ。
  monitorsDdc = pkgs.writeShellApplication {
    name = "monitors-ddc";
    runtimeInputs = [ pkgs.ddcutil ];
    text = builtins.readFile ./monitors-ddc;
  };

  # vicinae 用のメタデータを付与したモニタ制御スクリプトを生成する。
  # 引数: name (識別名), label (表示名), vcp (monitors-ddc に渡す引数), keywords (検索キーワード)
  # 返り値: 生成されたシェルスクリプトの derivation。
  monitorsCommand =
    {
      name,
      label,
      vcp,
      keywords,
    }:
    pkgs.writeShellScript "vicinae-monitors-${name}" ''
      # @vicinae.schemaVersion 1
      # @vicinae.title Monitors: ${label}
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

      ${monitorsDdc}/bin/monitors-ddc ${vcp}
    '';

  # モニタ入力を HDMI1 へ切り替える vicinae コマンド。
  # 消灯時でも確実に反映されるよう、D6 1 で点灯させてから入力を切り替える。
  monitorsHdmi1 = monitorsCommand {
    name = "hdmi1";
    label = "HDMI1";
    vcp = "D6 1 60 17";
    keywords = [ "hdmi" ];
  };

  # モニタ入力を USB-C へ切り替える vicinae コマンド。
  # 消灯時でも確実に反映されるよう、D6 1 で点灯させてから入力を切り替える。
  monitorsUsbc = monitorsCommand {
    name = "usbc";
    label = "USB-C";
    vcp = "D6 1 60 27";
    keywords = [
      "usb-c"
      "usbc"
      "type-c"
    ];
  };

  # モニタを消灯 (DPM Off) する vicinae コマンド。
  monitorsOff = monitorsCommand {
    name = "off";
    label = "OFF";
    vcp = "D6 4";
    keywords = [
      "off"
      "power"
    ];
  };
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

    # vicinae のスクリプト検索パスへモニタ制御コマンドを配置する。
    home.file = lib.mkIf config.mymodule.apps.vicinae.enable {
      ".local/share/vicinae/scripts/monitors-hdmi1".source = monitorsHdmi1;
      ".local/share/vicinae/scripts/monitors-usbc".source = monitorsUsbc;
      ".local/share/vicinae/scripts/monitors-off".source = monitorsOff;
    };
  };
}
