{ lib, ... }:
{
  options.mymodule.apps.mise = {
    enable = lib.mkEnableOption "mise dev tool manager and task runner";
  };
}
