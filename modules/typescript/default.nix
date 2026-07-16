{ lib, ... }:
{
  options.mymodule.apps.typescript = {
    enable = lib.mkEnableOption "TypeScript tools (deno, prettier)";
  };
}
