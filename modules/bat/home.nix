{ config, lib, pkgs, ... }:
{
  # macOS では brew(./darwin.nix) で導入する。
  config = lib.mkIf (config.mymodule.apps.bat.enable && pkgs.stdenv.hostPlatform.isLinux) {
    programs.bat.enable = true;
  };
}
