{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    terminal-darwin.enable = lib.mkEnableOption "Darwin specific terminal configuration";
  };

  config = lib.mkIf config.terminal-darwin.enable {
    # fish
    programs.fish = {
      enable = true;
      shellAbbrs = {
        copy = "pbcopy";
        paste = "pbpaste";
      };
      interactiveShellInit = ''
        fish_add_path /opt/homebrew/bin
      '';
    };

  };

}
