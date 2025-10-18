{ pkgs, ... }:
{
  imports = [
    ./darwin.nix
    ./linux.nix
  ];

  git-darwin.enable = pkgs.stdenv.isDarwin;
  git-linux.enable = pkgs.stdenv.isLinux;

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
