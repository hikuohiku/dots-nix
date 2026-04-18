{ lib, ... }:
{
  options.mymodule.apps.actions = {
    enable = lib.mkEnableOption "act (GitHub Actions runner)";
  };
}
