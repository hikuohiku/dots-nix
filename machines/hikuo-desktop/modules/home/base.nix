{
  userInfo,
  pkgs,
  ...
}:
rec {
  home.packages = [
    pkgs.claude-code
  ];

  mymodule.apps = {
    core.enable = true;
    fonts.enable = true;
    git.enable = true;
    cli-tools.enable = true;
    bat.enable = true;
    eza.enable = true;
    fzf.enable = true;
    gui-tools.enable = true;

    fish.enable = true;
    kitty.enable = true;
    zellij.enable = true;
    alacritty.enable = true;

    neovim.enable = true;
    vscode.enable = true;
    obsidian.enable = true;

    zen.enable = true;
    firefox.enable = true;

    syncthing.enable = true;

    # aylur.enable = true;
    # ml4w.enable = true;
  };

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
