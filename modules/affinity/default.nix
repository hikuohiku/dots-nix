{ lib, ... }:
{
  options.mymodule.apps.affinity = {
    enable = lib.mkEnableOption "Affinity Designer/Photo/Publisher via Bottles";
  };
}
