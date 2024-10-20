{
  pkgs,
  inputs,
  userInfo,
  ...
}:
rec {
  imports = [
    ./core.nix
    ./terminal.nix
    ./git.nix
    ./editor.nix
    ./browser.nix
    ./cli-tools.nix
    ./gui-tools.nix
    ./fileServer.nix
  ];

  # nixpkgs
  nixpkgs.config = {
    allowUnfree = true;
  };

  # home-manager
  home.username = userInfo.username;
  home.homeDirectory = "/home/${userInfo.username}";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # session environment variables
  home.sessionVariables = {
    XDG_CONFIG_HOME = "${home.homeDirectory}/.config";
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
}
