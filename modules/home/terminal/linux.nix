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
    # fish
    programs.fish = {
      enable = true;
      shellAbbrs = {
        copy = "wlcopy";
        paste = "wl-paste";
      };
      functions = {
        code = "command code $argv --enable-wayland-ime";
      };
      plugins = [
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
      ];
    };
    home.packages = with pkgs; [
      alacritty
    ];
  };

}
