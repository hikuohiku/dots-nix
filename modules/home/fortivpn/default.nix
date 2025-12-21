{ inputs, ... }:
{
  imports = [
    ./pac
  ]
  ++ inputs.my.lib.listPlatformModules ./.;
}
