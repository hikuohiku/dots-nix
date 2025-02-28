{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    terminal-linux.enable = lib.mkEnableOption "Linux specific terminal configuration";
  };

  config = lib.mkIf config.terminal-linux.enable {
    # alacritty
    programs.alacritty = {
      enable = true;
      settings = {
        decorations = "none";
      };
    };
  };

}
