{ pkgs, config, ... }:
let
  skhdWrapper = pkgs.writeShellScriptBin "skhd" ''
    exec /run/current-system/sw/bin/skhd "$@"
  '';
in
{
  disabledModules = [
    "services/skhd"
  ];

  environment.systemPackages = with pkgs; [
    skhd
  ];

  launchd.user.agents.skhd = {
    path = [ config.environment.systemPath ];

    serviceConfig.ProgramArguments = [ "${skhdWrapper}/bin/skhd" ];
    serviceConfig.KeepAlive = true;
    serviceConfig.ProcessType = "Interactive";
  };
}
