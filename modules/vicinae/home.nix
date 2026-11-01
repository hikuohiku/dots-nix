{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  monitorsInput = pkgs.writeShellApplication {
    name = "monitors-input";
    runtimeInputs = [ pkgs.ddcutil ];
    text = builtins.readFile ./monitors-input;
  };

  # 共有モニタの入力を切り替える vicinae のスクリプトコマンドを生成する。
  # 識別名・ラベル・入力値・キーワードを受け取り、monitors-input を呼び出すスクリプトを返す。
  monitorsInputCommand =
    {
      name,
      label,
      input,
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

      ${monitorsInput}/bin/monitors-input ${input}
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
      ".local/share/vicinae/scripts/monitors-hdmi1".source = monitorsInputCommand {
        name = "hdmi1";
        label = "HDMI1";
        input = "17";
        keywords = [ "hdmi" ];
      };
      ".local/share/vicinae/scripts/monitors-usbc".source = monitorsInputCommand {
        name = "usbc";
        label = "USB-C";
        input = "27";
        keywords = [
          "usb-c"
          "usbc"
          "type-c"
        ];
      };
    };
  };
}
