{
  config,
  pkgs,
  aylurpkgs,
  # overlays,
  inputs,
  userInfo,
  ...
}:
let
  username = userInfo.username;
  gitUsername = userInfo.git.username;
  gitEmail = userInfo.git.email;
  wallpaperPath = userInfo.wallpaperPath;
in
rec {
  nixpkgs.config = {
    allowUnfree = true;
    # permittedInsecurePackages = [
    #   "electron-29.4.6"
    # ];
  };
  nixpkgs.overlays = [ (import ./overlays/microsoft-edge-dev.nix) ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

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

    aylurpkgs.default
    # ========== TERMINAL ========== 
    alacritty

    # ========== EDITOR ========== 

    # ========== BROWSER ========== 
    microsoft-edge-dev

    # ========== CUI TOOL ========== 
    tree
    fastfetch
    gomi # trash
    bitwarden-cli

    # rust replace
    ripgrep # grep
    fd # find
    bat # cat
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
    # ========== LSP ========== 
    # Language Seervers
    nodePackages.bash-language-server # bash
    vscode-langservers-extracted # html, css, json, eslint
    marksman # md
    yaml-language-server # yaml
    taplo # toml
    nil # nix
    lua-language-server # lua

    # linters
    markdownlint-cli2 # md

    # ========== SCRIPT ========== 
    spectre-meltdown-checker

    # ========== OTHER TOOLS ========== 

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
      dotfilesRoot = /${home.homeDirectory}/.ghq/github.com/${username}/dotfiles;
      dotfiles = /${dotfilesRoot}/dotfiles;
    in
    {
      ".config/nvim" = {
        source = (symlink /home/hikuo/.ghq/github.com/hikuohiku/lazyvim);
        recursive = true;
      };
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
  };

  programs = {
    fish.enable = true;
    git = {
      enable = true;
      userName = gitUsername;
      userEmail = gitEmail;
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
    eza.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true; # $EDITOR=nvimに設定
      viAlias = true;
      vimAlias = true;
    };
    starship.enable = true;
    firefox.enable = true;
    kitty.enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = wallpaperPath;
      wallpaper = [ ",${wallpaperPath}" ];
    };
  };
  # services.swaync.enable = true;

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
