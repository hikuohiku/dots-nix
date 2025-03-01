{ pkgs, ... }:
{
  imports = [
    ./linux.nix
  ];

  gui-tools-linux.enable = pkgs.stdenv.isLinux;

}
