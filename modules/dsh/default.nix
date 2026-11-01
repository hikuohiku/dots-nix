{ lib, ... }:
{
  options.mymodule.apps.dsh = {
    enable = lib.mkEnableOption "DeepSeek Harness (dsh)";
  };
}
