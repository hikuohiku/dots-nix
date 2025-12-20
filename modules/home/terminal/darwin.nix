{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  # fish
  programs.fish = {
    enable = true;
    shellAbbrs = {
      copy = "pbcopy";
      paste = "pbpaste";
    };
    interactiveShellInit = ''
      fish_add_path /opt/homebrew/bin
    '';
  };
}
