{
  config,
  lib,
  ...
}:
{
  options = {
    fonts-darwin.enable = lib.mkEnableOption "Darwin specific fonts configuration";
  };

  config = lib.mkIf config.fonts-darwin.enable {
    # alacritty
    programs.alacritty = {
    };
  };

}
