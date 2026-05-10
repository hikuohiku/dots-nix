{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.zed.enable {
    homebrew.casks = [
      "zed"
    ];
  };
}
