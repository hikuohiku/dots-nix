{ pkgs, userInfo, ... }:
{
  imports = [
    ./darwin.nix
    ./linux.nix
  ];

  git-darwin.enable = pkgs.stdenv.isDarwin;
  git-linux.enable = pkgs.stdenv.isLinux;

  # git
  programs.git = {
    enable = true;
    userName = userInfo.git.username;
    userEmail = userInfo.git.email;
    ignores = [
      ".DS_Store"
    ];
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      pull.rebase = true;
      fetch.prune = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      commit.gpgsign = true;
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
    jujutsu
    lazyjj
  ];

  # lazygit
  programs.lazygit = {
    enable = true;
  };

  # jj config
  xdg.configFile = {
    "jj/config.toml" = {
      source = ./config.toml;
    };
  };
}
