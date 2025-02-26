{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    editor-darwin.enable = lib.mkEnableOption "Darwin specific editor configuration";
  };

  config = lib.mkIf config.editor-darwin.enable {
    # vscode
    home.packages = with pkgs; [
      vscode
    ];
  };

}
