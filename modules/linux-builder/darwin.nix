{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.linux-builder.enable {
    nix = {
      linux-builder = {
        enable = true;
        ephemeral = true;
        systems = [ "x86_64-linux" ];
        package = pkgs.darwin.linux-builder-x86_64;
      };

      settings.trusted-users = [ "@admin" ];
    };
  };
}
