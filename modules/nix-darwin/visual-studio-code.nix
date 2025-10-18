{ ... }:
{
  homebrew.casks = [
    "visual-studio-code"
  ];

  system.defaults.CustomUserPreferences = {
    "com.microsoft.VSCode" = {
      ApplePressAndHoldEnabled = false;
    };
  };

}
