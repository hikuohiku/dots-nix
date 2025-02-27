{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ========== Language Environment ==========
    gcc
    nodejs
    cargo
    python3
  ];
}
