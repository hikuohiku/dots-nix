{
  self,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./linux.nix
  ];

  editor-linux.enable = pkgs.stdenv.isLinux;

  home.packages = with pkgs; [
    neovim
    neovide
  ];

  # neovim
  home.file =
    let
      symlink = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      ".config/nvim" = {
        source = (symlink config.home.homeDirectory + /.ghq/github.com/hikuohiku/dots-nvim);
        recursive = true;
      };
    };
  home.sessionVariables = {
    EDITOR = "nvim";
  };

}
