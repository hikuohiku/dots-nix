{ lib, ... }:
{
  options.mymodule.apps.dms = {
    enable = lib.mkEnableOption "Dux Shell (DankMaterialShell)";
  };
}
