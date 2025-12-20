{ inputs, pkgs, ... }:
{
  imports = [
    (inputs.mylib.lib.mkModuleWithPlatform ./lazygit)
  ];

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
