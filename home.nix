{
  config,
  pkgs,
  overlays,
  inputs,
  ...
}:

rec {
  nixpkgs.config = {
    allowUnfree = true;
    # permittedInsecurePackages = [
    #   "electron-29.4.6"
    # ];
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "hikuo";
  home.homeDirectory = "/home/hikuo";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # theme 
    catppuccin

    # Nix
    nixVersions.nix_2_23

    # ========== NIXGL ========== 
    # nixgl.nixGLIntel

    # ========== TERMINAL ========== 
    alacritty
    kitty

    # ========== EDITOR & TOOLS ========== 
    vim-full
    felix
    micro
    neovim
    # visual-studio-code-bin
    # inputs.lem-editor.packages.x86_64-linux.lem-ncurses

    metals
    meson
    leiningen

    tig

    # ========== OTHER TOOLS ========== 
    # textimg
    # textql-git
    cachix
    unzip

    ghq
    cava
    lsd
    bat
    jnv
    jq

    lazydocker
    git

    jwt-cli

    slack
    teams-for-linux
    discord
    beeper

    # Teams for linux is depends to Electron-29 but EOL.
    # teams-for-linux

    teip

    tokei
    tree
    unar
    k6

    # esp32
    easyeffects
    espup
    espflash
    esptool
    cargo-espmonitor
    mkspiffs-presets.esp-idf

    # ========== BROWSER ========== 
    microsoft-edge-dev

    # ========== UTILS ========== 

    bitwarden-cli

    fastfetch

    fzf

    gomi # trash

    # resource monitor
    btop

    # zip
    p7zip # 7z

    # audio
    pavucontrol

    # file manager
    ranger

    rlwrap # readline wrapper

    rsync

    # rust replace
    ripgrep # grep
    fd # find
    sd # sed

    # scripts
    spectre-meltdown-checker

    # media player
    vlc

    # screen capture
    wf-recorder
    vhs # terminal screen capture
    # http
    wget
    httpie
    # clipboard
    wl-clipboard
    # launcher
    wofi

    # ========== OTHER TOOLS ========== 
    # hyprlock

    # analyze data format
    xsv
    yq

    # ========== LSP ========== 
    # Language Seervers
    nodePackages.bash-language-server # bash
    vscode-langservers-extracted # html, css, json, eslint
    marksman # md
    yaml-language-server # yaml
    nil # nix
    lua-language-server # lua

    # linters
    markdownlint-cli2 # md

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

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.

  # # Building this configuration will create a copy of 'dotfiles/screenrc' in
  # # the Nix store. Activating the configuration will then make '~/.screenrc' a
  # # symlink to the Nix store copy.
  # ".screenrc".source = dotfiles/screenrc;

  # # You can also set the file content immediately.
  # ".gradle/gradle.properties".text = ''
  #   org.gradle.console=verbose
  #   org.gradle.daemon.idletimeout=3600000
  # '';
  home.file =
    let
      symlink = config.lib.file.mkOutOfStoreSymlink;
      dotfilesRoot = /${home.homeDirectory}/.ghq/github.com/hikuo/dotfiles;
      dotfiles = /${dotfilesRoot}/dotfiles;
    in
    {
      # # ========== SKK ========== 
      # skk-dicts
      ".skk/SKK-JISYO.L".source = "${pkgs.skk-dicts}/share/SKK-JISYO.L";

      ".config/swaylock" = {
        source = (symlink /${dotfiles}/config/swaylock);
        recursive = true;
      };

      ".config/cava" = {
        source = (symlink /${dotfiles}/config/cava);
        recursive = true;
      };

      # ".config/fish" = {
      #   source = (symlink /${dotfiles}/config/fish);
      #   recursive = true;
      # };

      ".config/ime" = {
        source = (symlink /${dotfiles}/config/ime);
        recursive = true;
      };

      ".config/kitty" = {
        source = (symlink /${dotfiles}/config/kitty);
        recursive = true;
      };

      # ".config/kitty/kitty.conf" = {
      #   source = pkgs.substituteAll {
      #     name = "kitty_themes";
      #     kitty_themes = "${inputs.catppuccin-kitty}/themes";
      #     src = /${dotfiles}/config/kitty/kitty.conf;
      #   }; 
      # };

      ".config/libskk" = {
        source = (symlink /${dotfiles}/config/libskk);
        recursive = true;
      };

      ".config/nvim" = {
        source = (symlink /home/hikuo/.ghq/github.com/hikuohiku/lazyvim);
        recursive = true;
      };

      ".config/waybar" = {
        source = (symlink /${dotfiles}/config/waybar);
        recursive = true;
      };

      ".zshrc".source = (symlink /${dotfiles}/zshrc);
    };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/coma/etc/profile.d/hm-session-vars.sh

  home.sessionVariables = {
    # EDITOR = "nvim";
    XDG_CONFIG_HOME = "${home.homeDirectory}/.config";
    NIXOS_OZONE_WL = "1";
  };

  programs = {
    git = {
      enable = true;
      userName = "hikuohiku";
      userEmail = "hikuohiku@gmail.com";
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
          syntax-theme = "Nord";
        };
      };
    };

    lazygit = {
      enable = true;
      settings = {
        gui.language = "ja";
        git.paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format='lazygit-edit://{path}:{line}'";
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
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.hyprpaper =
    let
      wallpaperPath = "/home/hikuo/Pictures/wallpaper.jpg";
    in
    {
      enable = true;
      settings = {
        preload = wallpaperPath;
        wallpaper = [ ",${wallpaperPath}" ];
      };
    };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    settings = import ./hyprland.nix { inherit pkgs; };
    # https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
    systemd.variables = [ "--all" ];
  };
}
