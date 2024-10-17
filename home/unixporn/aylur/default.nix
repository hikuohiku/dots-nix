{
  pkgs,
  aylurpkgs,
  ...
}:
{
  imports = [ ./icon.nix ];

  home.packages = [
    aylurpkgs.default
  ];

  gtk.enable = true;

  catppuccin.enable = true;
  catppuccin.flavor = "latte";
  programs.starship.catppuccin.enable = true;

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

}
