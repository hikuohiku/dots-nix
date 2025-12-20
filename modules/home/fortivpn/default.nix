{ inputs, ... }:
{
  imports = [
    (inputs.mylib.lib.mkModuleWithPlatform ./pac)
  ];
}
