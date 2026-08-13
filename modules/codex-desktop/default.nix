{ lib, ... }:
{
  options.mymodule.apps.codex-desktop = {
    enable = lib.mkEnableOption "Codex Desktop (OpenAI 公式 Linux パッケージの非公式再配布)";
  };
}
