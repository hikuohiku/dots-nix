{ pkgs, ... }:
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
    LS_COLORS = "$(vivid generate catppuccin-latte)";
  };

  # packages
  home.packages = with pkgs; [
    grc
    vivid # LS_COLORS
  ];

  # alacritty
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty";
      window = {
        padding = {
          x = 8;
          y = 8;
        };
        opacity = 0.7;
      };
      font.size = 12;
      cursor = {
        style.shape = "Beam";
        style.blinking = "On";
        vi_mode_style.shape = "Block";
      };
    };
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
    ];
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
    settings = {
      default_mode = "locked";
      ui.pane_frames.rounded_corners = true;
    };
  };
}
