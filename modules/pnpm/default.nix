{ lib, ... }:
{
  options.mymodule.apps.pnpm = {
    enable = lib.mkEnableOption "pnpm package manager and Node.js manager";
  };
}
