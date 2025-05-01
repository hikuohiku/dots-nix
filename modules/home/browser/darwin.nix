{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    browser-darwin.enable = lib.mkEnableOption "Darwin specific browser configuration";
  };

  config = lib.mkIf config.browser-darwin.enable {
    home.file."Library/Application Support/zen/Profiles/hikuo/chrome" =
      let
        symlink = config.lib.file.mkOutOfStoreSymlink;
      in
      {
        recursive = true;
        source = (symlink config.home.homeDirectory + /.ghq/github.com/greeeen-dev/natsumi-browser);
      };
  };

}
