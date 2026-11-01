{ lib, ... }:
{
  options.mymodule.apps.bitwarden = {
    enable = lib.mkEnableOption "Bitwarden desktop and its SSH agent";
  };
}
