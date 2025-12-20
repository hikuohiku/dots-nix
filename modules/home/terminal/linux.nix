{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  # fish
  programs.fish = {
    enable = true;
    shellAbbrs = {
      copy = "wlcopy";
      paste = "wl-paste";
    };
    functions = {
      code = "command code $argv --enable-wayland-ime";
    };
    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
    ];
  };
  home.packages = with pkgs; [
    alacritty
  ];
}
