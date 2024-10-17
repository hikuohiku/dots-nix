{ pkgs, zen-browser, ... }:
{
  home.packages = with pkgs; [
    floorp
    microsoft-edge-dev
    zen-browser.default
  ];
  programs.firefox.enable = true;
  nixpkgs.overlays = [ (import ./overlays/microsoft-edge-dev.nix) ];
}
