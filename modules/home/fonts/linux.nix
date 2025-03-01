{
  config,
  lib,
  ...
}:
{
  options = {
    fonts-linux.enable = lib.mkEnableOption "Linux specific fonts configuration";
  };

  config = lib.mkIf config.fonts-linux.enable {
    # alacritty
    programs.alacritty = {
      settings = {
        font.size = 9;
      };
    };
  };

}
