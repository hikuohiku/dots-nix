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
        eval (zellij setup --generate-auto-start fish | sed 's/^\( *\)zellij attach -c$/\1zellij attach -c general/' | string collect)
      end
    ''
  );
}
