{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.vscode.enable {
    homebrew.casks = [ "visual-studio-code" ];
    system.defaults.CustomUserPreferences = {
      "com.microsoft.VSCode" = {
        ApplePressAndHoldEnabled = false;
      };
      "com.google.antigravity" = {
        ApplePressAndHoldEnabled = false;
      };
    };
  };
}
