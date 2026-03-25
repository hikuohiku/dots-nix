# vscode: Migrated to modules-2/vscode/
{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = with pkgs; [
    obsidian
  ];
}
