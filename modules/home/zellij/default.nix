{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    zellij
  ];

  xdg.configFile."zellij/config.kdl" = {
    source = ./config.kdl;
  };

  programs.fish.interactiveShellInit = (
    lib.mkOrder 200 ''
      if test "$TERM" = "alacritty"
        if not set -q ZELLIJ
          zellij
        end
      end
    ''
  );
}
