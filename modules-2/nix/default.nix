{ lib, ... }:
{
  options.mymodule.apps.nix = {
    enable = lib.mkEnableOption "Nix settings";
  };
}
