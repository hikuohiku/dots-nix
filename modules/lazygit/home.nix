{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.lazygit;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [ pkgs.lazygit ];
    }
    (lib.mkIf isDarwin {
      home.file."Library/Application Support/lazygit/config.yml".source = ./config.yml;
    })
    (lib.mkIf (!isDarwin) {
      xdg.configFile."lazygit/config.yml".source = ./config.yml;
    })
    (lib.mkIf config.programs.fish.enable {
      programs.fish.functions.lg = ''
        set -lx LAZYGIT_NEW_DIR_FILE (mktemp)
        lazygit $argv
        if test -s $LAZYGIT_NEW_DIR_FILE
          cd (cat $LAZYGIT_NEW_DIR_FILE)
        end
        rm -f $LAZYGIT_NEW_DIR_FILE
      '';
    })
  ]);
}
