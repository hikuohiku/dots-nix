{
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.file."Library/Application Support/lazygit/config.yml" = {
      source = ./lazygit-config.yml;
    };
  };
}
