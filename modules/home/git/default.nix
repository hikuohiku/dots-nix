{ pkgs, userInfo, ... }:
{
  imports = [
    ./darwin.nix
    ./linux.nix
  ];

  git-darwin.enable = pkgs.stdenv.isDarwin;
  git-linux.enable = pkgs.stdenv.isLinux; # Added support for Linux

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
  };
}
