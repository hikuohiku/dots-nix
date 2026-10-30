{ lib, ... }:
{
  options.mymodule.apps.prismlauncher = {
    enable = lib.mkEnableOption "Prism Launcher (Minecraft)";
  };
}
