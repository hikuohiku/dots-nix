{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.fzf.enable {
    programs.fzf = {
      enable = true;
      enableFishIntegration = false;
      defaultOptions = [
        "--cycle"
        "--layout=reverse"
        "--border"
        "--height=90%"
        "--preview-window=wrap"
        ''--marker="*"''
      ];
    };
  };
}
