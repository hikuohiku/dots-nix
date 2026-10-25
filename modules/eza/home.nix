{ config, lib, pkgs, ... }:
{
  # macOS では brew(./darwin.nix) で導入する。
  config = lib.mkIf (config.mymodule.apps.eza.enable && pkgs.stdenv.hostPlatform.isLinux) {
    programs.eza = {
      enable = true;
      enableFishIntegration = false;
    };
  };
}
