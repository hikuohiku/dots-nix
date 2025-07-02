{ ... }:
{
  homebrew.casks = [
    "visual-studio-code"
    "obsidian"
    "notion"
  ];

  system.defaults.CustomUserPreferences = {
    "com.microsoft.VSCode" = {
      ApplePressAndHoldEnabled = false;
    };
  };

}
