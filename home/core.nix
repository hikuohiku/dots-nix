{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard # clipboard
    openssl # ssl
    libnotify # norify-send

    # ========== Language Environment ==========
    # should be dependency of some pakcages so put here
    gcc
    nodejs
    cargo
  ];
}
