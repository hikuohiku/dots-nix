{ pkgs, ... }:
{
  # x86_64 linux builder
  nix = {
    linux-builder = {
      enable = true;
      systems = [ "x86_64-linux" ];
      package = pkgs.darwin.linux-builder-x86_64;
    };

    settings.trusted-users = [ "@admin" ];
  };
}
