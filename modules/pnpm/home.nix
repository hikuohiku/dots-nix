{
  config,
  lib,
  pkgs,
  ...
}:
let
  pnpmHome = "${config.xdg.dataHome}/pnpm";
in
{
  config = lib.mkIf config.mymodule.apps.pnpm.enable {
    home.packages = with pkgs; [
      pnpm
    ];

    home.sessionVariables.PNPM_HOME = pnpmHome;
    home.sessionPath = [
      "${pnpmHome}/bin"
      pnpmHome
    ];
  };
}
