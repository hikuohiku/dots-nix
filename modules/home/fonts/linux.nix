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
  };

}
