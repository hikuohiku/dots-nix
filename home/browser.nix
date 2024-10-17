{ pkgs, zen-browser, ... }:
{
  home.packages = with pkgs; [
    floorp
    microsoft-edge-dev
    zen-browser.default
  ];
  nixpkgs.overlays = [ (import ./overlays/microsoft-edge-dev.nix) ];
}
