{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.git.enable {
    homebrew.brews = [ "git" "git-delta" "ghq" ];
  };
}
