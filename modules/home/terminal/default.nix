{ inputs, pkgs, ... }:
{
  imports = [
    ./linux.nix
    ./darwin.nix
    ./zellij.nix
  ];

  terminal-linux.enable = pkgs.stdenv.isLinux;
  terminal-darwin.enable = pkgs.stdenv.isDarwin;

  home.sessionVariables = {
    ZELLIJ_AUTO_ATTACH = "true";
    LS_COLORS = "$(vivid generate tokyonight-moon)";
  };

  # packages
  home.packages = with pkgs; [
    grc
    vivid # LS_COLORS
    claude-code
  ];

  # alacritty
  xdg.configFile."alacritty/alacritty.toml" = {
    source = ./alacritty.toml;
  };
  # kitty
  programs.kitty.enable = true;

  # fish
  programs.fish = {
    enable = true;
    shellAbbrs = {
      ls = "eza --color=auto --icons";
      l = "eza --color=auto --icons -lah";
      ll = "eza --color=auto --icons -l";
      la = "eza --color=auto --icons -a";
      cat = "bat";
      find = "fd";
      grep = "rg";
      sed = "sd";
      top = "btop";
      du = "dua";
      rm = "gomi";
      c = "code";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      n = "neovide";
      g = "git";
      lg = "lazygit";
      lspath = "echo $PATH | sed 's/ /\\n/g' | sort";
      ja = "trans -b :ja";
      cp = "cp -r";
      "-" = "prevd";
      "+" = "nextd";
      zl = "zellij a";
      tree = "eza --color=auto --icons -a --tree";
    };
    functions = {
      gitignore = "curl -sL https://www.gitignore.io/api/$argv";
      nr = "nix run nixpkgs#$argv[1] -- $argv[2..]";
      ssh = ''
        # ZELLIJ環境変数が設定されているかを確認
        if test -n "$ZELLIJ"
            echo "Please detach zellij session before starting ssh connection."
        else
            # 実際のsshコマンドを実行
            command ssh $argv
        end
      '';
      mkenv = "cp ~/environments/$argv[1]/flake.nix ./flake.nix && echo 'use flake' > .envrc && direnv allow";
    };
    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "fzf";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "fish-ghq";
        src = inputs.fish-ghq;
      }
    ];
    interactiveShellInit = ''
      bind ctrl-s '__ghq_repository_search'
      bind ctrl-q delete-or-exit
      bind shift-tab complete
      bind tab '
        if commandline --search-field >/dev/null
          commandline -f complete
        else
          commandline -f complete-and-search
        end
      '
      fzf_configure_bindings --git_log= --git_status= --processes= --directory=ctrl-d
      complete -c uv -n '__fish_seen_subcommand_from remove' -xa '(yq -r ".project.dependencies[]" pyproject.toml)'
      complete -c ghq -n '__fish_seen_subcommand_from get' -xa "(gh repo list --json name,owner --jq '.[] | select(.owner.login==\"hikuohiku\") | .owner.login + \"/\" + .name' 2>/dev/null)"
      set -g fzf_fd_opts --no-ignore
    '';
  };
  # starship
  programs.starship = {
    enable = true;
  };

  # zellij
  # alacrittyでのみターミナル起動時にzellijを起動するためにカスタムモジュールを作成している ./zellij.nix
  programs.my-zellij = {
    enable = true;
    enableFishIntegration = true;
    # settings = {
    #   default_mode = "locked";
    #   ui.pane_frames.rounded_corners = true;
    # };
  };
}
