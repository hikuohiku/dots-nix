{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.fonts.enable {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.symbols-only
        sarasa-gothic
        plemoljp
        plemoljp-nf
      ];
    };
  };
}
