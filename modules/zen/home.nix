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
        "text/html" = "zen-beta.desktop";
        "application/xhtml+xml" = "zen-beta.desktop";
        "x-scheme-handler/http" = "zen-beta.desktop";
        "x-scheme-handler/https" = "zen-beta.desktop";
        "x-scheme-handler/ftp" = "zen-beta.desktop";
        "x-scheme-handler/about" = "zen-beta.desktop";
      };
    })
  ]);
}
