{ inputs, ... }:
{
  imports = [
    ./pac
  ]
  ++ inputs.mylib.lib.listPlatformModules ./.;
}
