{ pkgs, ... }:
{
  imports = [
    ./darwin.nix
    ./linux.nix
  ];

  browser-darwin.enable = pkgs.stdenv.isDarwin;
  browser-linux.enable = pkgs.stdenv.isLinux; # Added support for Linux

}
