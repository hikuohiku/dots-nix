{ pkgs, ... }:
{
  imports = [
    ./linux.nix
  ];

  core-linux.enable = pkgs.stdenv.isLinux;

  home.packages = with pkgs; [
    # ========== Language Environment ==========
    nodejs
    cargo
    uv
    nil
    nixfmt-rfc-style
  ];
}
