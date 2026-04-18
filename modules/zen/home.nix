{
  config,
  lib,
  pkgs,
  inputs',
  ...
}:
let
  cfg = config.mymodule.apps.zen;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf isLinux {
      home.packages = [
        inputs'.zen-browser.packages.default
      ];
      xdg.mimeApps.defaultApplications = {
        "text/html" = "zen.desktop";
        "application/xhtml+xml" = "zen.desktop";
        "x-scheme-handler/http" = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "x-scheme-handler/ftp" = "zen.desktop";
        "x-scheme-handler/about" = "zen.desktop";
      };
    })
  ]);
}
