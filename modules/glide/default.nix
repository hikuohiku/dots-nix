{ lib, ... }:
{
  options.mymodule.apps.glide = {
    enable = lib.mkEnableOption "Glide";
  };
}
