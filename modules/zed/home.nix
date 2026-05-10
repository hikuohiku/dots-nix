{ config, lib, ... }:
let
  cfg = config.mymodule.apps.zed;
in
{
  config = lib.mkIf cfg.enable {
    home.file.".config/zed" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/ghq/github.com/hikuohiku/dots-zed";
      recursive = true;
    };
  };
}
