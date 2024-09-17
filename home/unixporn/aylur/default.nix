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

  catppuccin.enable = true;
  catppuccin.flavor = "latte";
  programs.neovim.enable = false;
}
