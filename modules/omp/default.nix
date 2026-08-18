{ lib, ... }:
{
  options.mymodule.apps.omp = {
    enable = lib.mkEnableOption "omp (oh-my-pi) coding agent";
  };
}
