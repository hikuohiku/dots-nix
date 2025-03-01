{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    core-linux.enable = lib.mkEnableOption "Linux specific core packages configuration";
  };

  config = lib.mkIf config.core-linux.enable {
    home.packages = with pkgs; [
      wl-clipboard # clipboard
      openssl # ssl
      libnotify # norify-send
    ];
  };

}
