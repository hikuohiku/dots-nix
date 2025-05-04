{ pkgs, userInfo, ... }:
{
  # git
  programs.git = {
    enable = true;
    userName = userInfo.git.username;
    userEmail = userInfo.git.email;
    ignores = [
      ".DS_Store"
    ];
    extraConfig = {
      ghq = {
        root = "~/.ghq";
      };
      init = {
        defaultBranch = "main";
      };
      pull.rebase = true;
      fetch.prune = true;
    };
    delta = {
      enable = true;
      options = {
        dark = true;
      };
    };
  };

  # ghq
  home.packages = with pkgs; [
    ghq
  ];

  # lazygit
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        language = "ja";
        nerdFontsVersion = "3";
      };
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format='lazygit-edit://{path}:{line}'";
        };
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
}
