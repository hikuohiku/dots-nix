{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.nix.enable {
    nix.extraOptions = ''
      extra-experimental-features = nix-command flakes pipe-operators
    '';
    nix.settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://hikuohiku.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hikuohiku.cachix.org-1:AZwUw2nnqdfm6k5oLyczGRRHMBEQXz0Fo1HzI+RwApg="
      ];
    };
  };
}
