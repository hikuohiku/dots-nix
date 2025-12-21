{ inputs, pkgs, ... }:
{
  imports = inputs.mylib.lib.listPlatformModules ./.;
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
