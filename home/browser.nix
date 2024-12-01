{ pkgs, zen-browser, ... }:
{
  home.packages = with pkgs; [
    microsoft-edge-dev
    zen-browser.default
  ];
  programs.firefox.enable = true;

  xdg.mimeApps.defaultApplications = {
    "text/html"="zen.desktop";
    "application/xhtml+xml"="zen.desktop";
    "x-scheme-handler/http"="zen.desktop";
    "x-scheme-handler/https"="zen.desktop";
    "x-scheme-handler/ftp"="zen.desktop";
    "x-scheme-handler/about"="zen.desktop";
  };

  nixpkgs.overlays = [ (import ./overlays/microsoft-edge-dev.nix) ];
}
