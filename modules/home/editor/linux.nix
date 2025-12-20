{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  # vscode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };
  # TODO: overlayで設定にする
  xdg.desktopEntries = {
    code = {
      actions.new-empty-window = {
        name = "New Empty Window";
        exec = "code --enable-wayland-ime --new-window %F";
        icon = "vscode";
      };
      categories = [
        "Utility"
        "TextEditor"
        "Development"
        "IDE"
      ];
      comment = "Code Editing. Redefined.";
      exec = "code --enable-wayland-ime %F";
      genericName = "Text Editor";
      icon = "vscode";
      name = "Visual Studio Code";
      startupNotify = true;
      type = "Application";
    };
  };

  home.packages = with pkgs; [
    obsidian
  ];
}
