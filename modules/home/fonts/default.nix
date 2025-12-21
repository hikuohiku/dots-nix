{ inputs, ... }:
{
  imports = inputs.my.lib.listPlatformModules ./.;
}
