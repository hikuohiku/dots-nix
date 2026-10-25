{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.go.enable {
    homebrew.brews = [ "go" "gopls" ];
  };
}
