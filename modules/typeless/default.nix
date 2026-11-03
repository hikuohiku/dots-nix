{ lib, ... }:
{
  options.mymodule.apps.typeless = {
    enable = lib.mkEnableOption "Typeless voice dictation";
  };
}
