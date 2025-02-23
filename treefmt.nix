{ ... }:
{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    yamlfmt.enable = true;
  };

  settings.formatter = {
  };
}
