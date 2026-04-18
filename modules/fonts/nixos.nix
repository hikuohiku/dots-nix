{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.fonts.enable {
    fonts = {
      packages = with pkgs; [
        noto-fonts-cjk-serif
        source-han-sans-vf-ttf
        sarasa-gothic
        plemoljp
        plemoljp-nf
        noto-fonts-color-emoji
        nerd-fonts.symbols-only
      ];
      enableDefaultPackages = false;
      fontDir.enable = true;
      fontconfig = {
        defaultFonts = {
          serif = [
            "Noto Serif CJK JP"
            "Noto Color Emoji"
          ];
          sansSerif = [
            "Source Han Sans VF"
            "Noto Color Emoji"
          ];
          monospace = [
            "Sarasa Mono J SemiBold"
            "Noto Color Emoji"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}