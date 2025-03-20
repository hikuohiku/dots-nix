{ pkgs, ... }:
{
  home.packages = with pkgs; [
    aerospace
  ];
  xdg.configFile = {
    "aerospace/aerospace.toml" = {
      source = ./aerospace.toml;
    };
  };
}
