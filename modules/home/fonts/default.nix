{ pkgs, ... }:
{
  imports = [
    ./linux.nix
    ./darwin.nix
  ];

  fonts-linux.enable = pkgs.stdenv.isLinux;
  fonts-darwin.enable = pkgs.stdenv.isDarwin;

  # alacritty
  programs.alacritty = {
    settings = {
      font.normal = {
        family = "PlemolJP35 Console NF";
        style = "Medium";
      };
    };
  };
}
