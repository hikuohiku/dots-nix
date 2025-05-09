{
  config,
  lib,
  inputs',
  ...
}:
{
  options = {
    browser-linux.enable = lib.mkEnableOption "Linux specific browser configuration";
  };

  config = lib.mkIf config.browser-linux.enable {
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
  };
}
