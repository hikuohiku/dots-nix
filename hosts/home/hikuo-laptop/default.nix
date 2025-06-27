{
  userInfo,
  ...
}:
rec {
  imports = [
    ../../../modules/home/core
    ../../../modules/home/fonts
    ../../../modules/home/terminal
    # ../../../modules/home/git
    # ../../../modules/home/editor
    # ../../../modules/home/browser
    # ../../../modules/home/cli-tools.nix
    # ../../../modules/home/gui-tools
    # ../../../modules/home/fileServer.nix
    # ../../../modules/home/unixporn/aylur
  ];

  # home-manager
  home.username = userInfo.username;
  home.homeDirectory = "/home/${userInfo.username}";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # session environment variables
  home.sessionVariables = {
    XDG_CONFIG_HOME = "${home.homeDirectory}/.config";
  };

  xdg.mimeApps.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
