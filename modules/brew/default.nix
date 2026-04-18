{ lib, ... }:
{
  options.mymodule.apps.brew = {
    enable = lib.mkEnableOption "Homebrew casks / brews / MAS apps bundle";
  };
}
