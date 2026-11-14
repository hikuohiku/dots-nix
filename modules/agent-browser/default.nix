{ lib, ... }:
{
  options.mymodule.apps.agent-browser = {
    enable = lib.mkEnableOption "agent-browser, a browser automation CLI for AI agents";
  };
}
