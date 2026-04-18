{ lib, ... }:
{
  options.mymodule.apps.syncthing = {
    enable = lib.mkEnableOption "Syncthing";
  };
}
