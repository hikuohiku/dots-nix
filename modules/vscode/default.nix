{ lib, ... }:
{
  options.mymodule.apps.vscode = {
    enable = lib.mkEnableOption "Visual Studio Code";
  };
}
