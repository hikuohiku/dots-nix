{
  config,
  lib,
  inputs',
  ...
}:
{
  options = {
    git-linux.enable = lib.mkEnableOption "Linux specific git configuration";
  };

  config = lib.mkIf config.git-linux.enable {
    xdg.configFile = {
      "lazygit/config.yml" = {
        source = ./lazygit-config.yml;
      };
    };
  };
}
