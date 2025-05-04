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
        allBranchesLogCmd = "git log --graph --color=always --date=format:'%Y-%m-%d %H:%M' --pretty=format:'%C(#a0a0a0 reverse)%h%Creset %C(cyan)%ad%Creset %C(#dd4814)%ae%Creset %C(yellow reverse)%d%Creset %n%C(white bold)%s%Creset%n'";
        branchLogCmd = "git log --graph --color=always --date=format:'%Y-%m-%d %H:%M' --pretty=format:'%C(#a0a0a0 reverse)%h%Creset %C(cyan)%ad%Creset %C(#dd4814)%ae%Creset %C(yellow reverse)%d%Creset %n%C(white bold)%s%Creset%n' {{branchName}}";
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
