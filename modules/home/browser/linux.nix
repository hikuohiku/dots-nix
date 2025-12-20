{ lib, pkgs, inputs', ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [
    inputs'.zen-browser.packages.default
  ];
  programs.firefox.enable = true;

  xdg.mimeApps.defaultApplications = {
    "text/html" = "zen.desktop";
    "application/xhtml+xml" = "zen.desktop";
    "x-scheme-handler/http" = "zen.desktop";
    "x-scheme-handler/https" = "zen.desktop";
    "x-scheme-handler/ftp" = "zen.desktop";
    "x-scheme-handler/about" = "zen.desktop";
  };
}
