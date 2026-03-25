{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.neovim;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      neovim
    ];

    home.file.".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/ghq/github.com/hikuohiku/dots-nvim";
      recursive = true;
    };

    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
