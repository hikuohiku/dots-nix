{ lib, ... }:
{
  options.mymodule.apps.dotnet = {
    enable = lib.mkEnableOption ".NET SDK 10";
  };
}
