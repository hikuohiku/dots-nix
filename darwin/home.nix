{
  pkgs,
  lib,
  userInfo,
  ...
}:
{
  # git
  programs.git = {
    enable = true;
    userName = userInfo.git.username;
    userEmail = userInfo.git.email;
    extraConfig = {
      ghq = {
        root = "~/.ghq";
      };
      init = {
        defaultBranch = "main";
      };
    };
    delta = {
      enable = true;
      options = {
        dark = false;
      };
    };
  };

  # ghq
  home.packages = with pkgs; [
    ghq
    vscode
  ];

  # lazygit
  programs.lazygit = {
    enable = true;
    settings = {
      gui.language = "ja";
      git.paging = {
        colorArg = "always";
        pager = "delta --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format='lazygit-edit://{path}:{line}'";
      };
      # TODO: git cz
      # customCommands:
      #   - key: "C"
      #     command: "git cz"
      #     description: "commit with commitizen"
      #     context: "files"
      #     loadingText: "opening commitizen commit tool"
      #     subprocess: true
    };
  };

  # home-manager
  home.username = userInfo.username;
  home.homeDirectory = lib.mkForce "/Users/${userInfo.username}";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
}
