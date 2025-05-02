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
  };

}
