{ config, pkgs, ... }:
{
  imports = [
    ./linux.nix
    ./darwin.nix
  ];

  editor-linux.enable = pkgs.stdenv.isLinux;
  editor-darwin.enable = pkgs.stdenv.isDarwin;

  home.packages = with pkgs; [
    neovim
    neovide
    obsidian
  ];

  # neovim
  home.file =
    let
      symlink = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      ".config/nvim" = {
        source = (symlink /home/hikuo/.ghq/github.com/hikuohiku/lazyvim);
        recursive = true;
      };
    };
  home.sessionVariables = {
    EDITOR = "nvim";
  };

}
