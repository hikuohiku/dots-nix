{
  pkgs,
  inputs,
  userInfo,
  ...
}:
rec {
  imports = [
    ./terminal.nix
    ./editor.nix
    ./browser.nix
  ];

  # nixpkgs
  nixpkgs.config = {
    allowUnfree = true;
  };

  # home-manager
  home.username = userInfo.username;
  home.homeDirectory = "/home/${userInfo.username}";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # session environment variables
  home.sessionVariables = {
    XDG_CONFIG_HOME = "${home.homeDirectory}/.config";
    EDITOR = "nvim";
    ZELLIJ_AUTO_ATTACH = "true";
    ZELLIJ_AUTO_EXIT = "true";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # ========== SYSTEM ========== 
    # colorscheme
    catppuccin

    # audio
    pavucontrol

    # screen capture
    wf-recorder
    vhs # terminal screen capture

    # clipboard
    wl-clipboard

    # launcher
    wofi

    # hyprlock

    openssl

    # ========== CUI TOOL ========== 
    tree
    fastfetch
    gomi # trash
    bitwarden-cli

    # rust replace
    ripgrep # grep
    fd # find
    sd # sed

    # archive
    unar # unarchiver
    unzip
    p7zip # 7z

    # file management
    ghq
    rsync

    # http
    wget
    httpie

    # analyze data format
    xsv
    yq
    jwt-cli
    jq
    jnv

    # ========== TUI TOOL ========== 
    btop # resource monitor
    ranger # file manager
    lazydocker

    # ========== GUI APPLICATION ========== 
    # social
    slack
    teams-for-linux
    discord

    # media player
    vlc

    # file manager
    nautilus
    # ========== UTIL ========== 
    fzf
    rlwrap # readline wrapper

    # ========== Language Environment ========== 
    gcc
    nodejs
    cargo

    # ========== SCRIPT ========== 
    spectre-meltdown-checker

    # ========== OTHER TOOLS ========== 
    # skk-dicts

    # flatpak https://wiki.nixos.org/wiki/Flatpak
    flatpak
    gnome-software
    # ================================== 

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs = {
    git = {
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

    lazygit = {
      enable = true;
      settings = {
        gui.language = "ja";
        git.paging = {
          colorArg = "always";
          pager = "delta --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format='lazygit-edit://{path}:{line}'";
        };
        # customCommands:
        #   - key: "C"
        #     command: "git cz"
        #     description: "commit with commitizen"
        #     context: "files"
        #     loadingText: "opening commitizen commit tool"
        #     subprocess: true
      };
    };
    bat.enable = true;
    eza.enable = true;
    firefox.enable = true;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = userInfo.wallpaperPath;
      wallpaper = [ ",${userInfo.wallpaperPath}" ];
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    settings = import ./hyprland.nix { inherit pkgs; };
    # https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
    systemd.variables = [ "--all" ];
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
}
