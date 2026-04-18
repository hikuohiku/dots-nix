{
  userInfo,
  pkgs,
  ...
}:
rec {
  home.packages = [
    pkgs.claude-code
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  home.username = userInfo.username;
  home.homeDirectory = "/home/${userInfo.username}";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    XDG_CONFIG_HOME = "${home.homeDirectory}/.config";
  };

  xdg.mimeApps.enable = true;

  home.stateVersion = "24.05";
}
