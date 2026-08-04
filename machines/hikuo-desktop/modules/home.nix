{
  lib,
  pkgs,
  userInfo,
  ...
}:
{
  home.username = userInfo.username;
  home.homeDirectory = lib.mkForce "/home/${userInfo.username}";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    XDG_CONFIG_HOME = "/home/${userInfo.username}/.config";
  };

  xdg.mimeApps.enable = true;

  # voicist/prototype の Makefile / .agents/agent-team.mk をタスクランナーとして回すため。
  # make は dev shell (nix develop/devenv) 内では stdenv 経由で入るが、shell 外では
  # 入らない。buf は post-change が protobuf/ の変更時に要求する。
  home.packages = with pkgs; [
    gnumake
    buf
  ];

  programs.dank-material-shell = {
    enable = true;
  };

  home.stateVersion = "24.05";
  home.enableNixpkgsReleaseCheck = false;
}
