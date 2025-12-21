{ mylib, ... }:
{
  imports = [
    ./pac
  ]
  ++ mylib.listPlatformModules ./.;
}
