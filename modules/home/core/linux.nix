{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard # clipboard
    openssl # ssl
    libnotify # norify-send
  ];
}
