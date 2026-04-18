{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.ghostty.enable {
    homebrew.casks = [
      "ghostty"
    ];
  };
}
