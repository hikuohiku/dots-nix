{
  aylurpkgs,
  ...
}:
{
  imports = [ ./icon.nix ];

  home.packages = [
    aylurpkgs.default
  ];

  gtk.enable = true;
}
