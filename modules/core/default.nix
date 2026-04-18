{ lib, ... }:
{
  options.mymodule.apps.core = {
    enable = lib.mkEnableOption "core language environment packages";
  };
}
