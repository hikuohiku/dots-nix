{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    git-darwin.enable = lib.mkEnableOption "Darwin specific git configuration";
  };

  config = lib.mkIf config.git-darwin.enable {
    home.file."Library/Application Support/lazygit/config.yml" = {
      source = ./lazygit-config.yml;
    };
  };

}
