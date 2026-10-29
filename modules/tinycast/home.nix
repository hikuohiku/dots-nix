{
  config,
  lib,
  pkgs,
  ...
}:
let
  monitorsInput = pkgs.writeShellApplication {
    name = "monitors-input";
    runtimeInputs = [ pkgs.m1ddc ];
    text = builtins.readFile ./monitors-input;
  };

  # Tinycast が取り込む Raycast 形式のスクリプトコマンドを作る。
  # 取り込み時に shebang のインタプリタのパスが固定されるので、store の bash ではなく
  # /bin/bash を使う（store のパスは GC で消える）。
  monitorsInputCommand =
    {
      name,
      label,
      input,
      keywords,
    }:
    pkgs.writeScript "tinycast-monitors-${name}" ''
      #!/bin/bash
      # @raycast.schemaVersion 1
      # @raycast.title Monitors: ${label}
      # @raycast.mode silent
      # @raycast.keywords ${
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
  config = lib.mkIf config.mymodule.apps.tinycast.enable {
    home.file.".local/share/tinycast/scripts/monitors-hdmi1".source = monitorsInputCommand {
      name = "hdmi1";
      label = "HDMI1";
      input = "17";
      keywords = [ "hdmi" ];
    };
    home.file.".local/share/tinycast/scripts/monitors-usbc".source = monitorsInputCommand {
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
}
