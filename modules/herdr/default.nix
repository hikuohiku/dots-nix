{ lib, ... }:
{
  options.mymodule.apps.herdr = {
    enable = lib.mkEnableOption "Herdr agent multiplexer";
  };
}
