{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.skhd;
  skhdWrapper = pkgs.writeShellScriptBin "skhd" ''
    exec /run/current-system/sw/bin/skhd "$@"
  '';
in
{
  disabledModules = [
    "services/skhd"
  ];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.skhd ];

    launchd.user.agents.skhd = {
      path = [ config.environment.systemPath ];
      serviceConfig.ProgramArguments = [ "${skhdWrapper}/bin/skhd" ];
      serviceConfig.KeepAlive = true;
      serviceConfig.ProcessType = "Interactive";
    };
  };
}
