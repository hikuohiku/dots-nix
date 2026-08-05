{
  config,
  lib,
  pkgs,
  ...
}:
let
  sdk = pkgs.dotnetCorePackages.sdk_8_0;
in
{
  config = lib.mkIf config.mymodule.apps.dotnet.enable {
    home.packages = [ sdk ];

    home.sessionVariables = {
      DOTNET_ROOT = "${sdk}/share/dotnet";
      DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    };

    # dotnet tool install -g の配置先
    home.sessionPath = [ "${config.home.homeDirectory}/.dotnet/tools" ];
  };
}
