{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.affinity.enable {
    environment.systemPackages = with pkgs; [
      bottles
    ];

    # Wine が必要とする 32bit OpenGL サポート
    hardware.graphics.enable32Bit = true;
  };
}
