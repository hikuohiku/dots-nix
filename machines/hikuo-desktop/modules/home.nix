{
  lib,
  userInfo,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.claude-code
  ];

  home.username = userInfo.username;
  home.homeDirectory = lib.mkForce "/home/${userInfo.username}";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    XDG_CONFIG_HOME = "/home/${userInfo.username}/.config";
  };

  xdg.mimeApps.enable = true;

  home.stateVersion = "24.05";
}
