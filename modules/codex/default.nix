{ lib, ... }:
{
  options.mymodule.apps.codex = {
    enable = lib.mkEnableOption "Codex global skills & shared AGENTS.md";
  };
}
