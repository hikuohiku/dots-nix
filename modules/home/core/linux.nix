{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = with pkgs; [
    wl-clipboard # clipboard
    openssl # ssl
    libnotify # norify-send
  ];
}
