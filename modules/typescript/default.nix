{ lib, ... }:
{
  options.mymodule.apps.typescript = {
    enable = lib.mkEnableOption "TypeScript runtimes (deno, pnpm, prettier)";
  };
}
