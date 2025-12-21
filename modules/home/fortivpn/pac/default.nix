{ inputs, ... }:
{
  imports = inputs.mylib.lib.listPlatformModules ./.;
}
