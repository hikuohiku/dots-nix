{ pkgs, ... }:
{
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
      window = {
        padding = {
          x = 8;
          y = 8;
        };
        decorations = "none";
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
      copy = "wl-copy";
      paste = "wl-paste";
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
      c = "code";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      n = "neovide";
      g = "git";
      lg = "lazygit";
      lspath = "echo $PATH | sed 's/ /\\n/g' | sort";
      ja = "trans -b :ja";
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
        name = "done";
        src = pkgs.fishPlugins.done.src;
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
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      default_mode = "locked";
      ui.pane_frames.rounded_corners = true;
    };
  };
}
