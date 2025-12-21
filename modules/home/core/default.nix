{ inputs, pkgs, ... }:
{
  imports = inputs.my.lib.listPlatformModules ./.;
  home.packages = with pkgs; [
    # ========== Language Environment ==========
    nodejs
    cargo
    uv
    nil
    nixfmt-rfc-style
    nixd
  ];
}
