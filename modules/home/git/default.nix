{ pkgs, lib, ... }:
{
  imports = lib.fileset.fileFilter (file: file.hasExt "nix") ./lazygit |> lib.fileset.toList;

  home.packages = with pkgs; [
    git
    delta
    ghq
  ];

  xdg.configFile = {
    "git/config" = {
      source = ./config;
    };
    "git/ignore" = {
      source = ./ignore;
    };
  };

  # lazygit
  programs.lazygit = {
    enable = true;
  };
}
