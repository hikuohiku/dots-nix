{
  lib,
  userInfo,
  ...
}:
{
  home.username = userInfo.username;
  home.homeDirectory = lib.mkForce "/home/${userInfo.username}";
  home.stateVersion = "26.11";
  programs.home-manager.enable = true;
}
