{ pkgs, ... }:
{
  imports = [
    ./linux.nix
    ./darwin.nix
  ];

  fonts-linux.enable = pkgs.stdenv.isLinux;
  fonts-darwin.enable = pkgs.stdenv.isDarwin;
}
