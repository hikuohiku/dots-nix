{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.fzf.enable {
    # macOS では brew(./darwin.nix) で導入する。
    home.packages = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.fzf;
    home.sessionVariables.FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
      "--cycle"
      "--layout=reverse"
      "--border"
      "--height=90%"
      "--preview-window=wrap"
      ''--marker="*"''
    ];
  };
}
