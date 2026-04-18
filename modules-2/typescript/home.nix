{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.typescript.enable {
    home.packages = with pkgs; [
      deno
      pnpm
      nodePackages_latest.prettier
    ];
  };
}
