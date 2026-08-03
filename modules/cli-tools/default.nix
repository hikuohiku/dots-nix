{ lib, ... }:
{
  options.mymodule.apps.cli-tools = {
    enable = lib.mkEnableOption "CLI tool collection";
    base.enable = lib.mkEnableOption "base CLI tools";
    development.enable = lib.mkEnableOption "development CLI tools";
    infrastructure.enable = lib.mkEnableOption "infrastructure CLI tools";
    automation.enable = lib.mkEnableOption "automation CLI tools";
    documents.enable = lib.mkEnableOption "document authoring CLI tools";
    secrets.enable = lib.mkEnableOption "secrets CLI tools";
    recording.enable = lib.mkEnableOption "terminal recording CLI tools";
  };
}
