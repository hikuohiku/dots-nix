{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.mymodule.apps.typescript.enable {
    home.packages = with pkgs; [
      deno
      nodePackages_latest.prettier
    ];
  };
}
