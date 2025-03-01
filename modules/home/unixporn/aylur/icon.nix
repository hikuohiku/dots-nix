{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hicolor-icon-theme
  ];

  gtk.iconTheme = {
    name = "Papirus-Light";
    package = pkgs.papirus-icon-theme;
  };
}
