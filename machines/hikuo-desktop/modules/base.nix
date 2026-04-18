{
  pkgs,
  userInfo,
  systemInfo,
  ...
}:
{
  imports = [
    ./hardware.nix # ハードウェア設定
    ./nvidia.nix # NVIDIA固有の設定
    ./remotebuild.nix
  ];

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;

  networking = {
    hostName = systemInfo.hostname;
    networkmanager.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  boot.loader = {
    grub = {
      enable = true;
      useOSProber = true;
      efiSupport = true;
      device = "nodev";
    };
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Asia/Tokyo";
  i18n = {
    defaultLocale = "ja_JP.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "ja_JP.UTF-8";
      LC_IDENTIFICATION = "ja_JP.UTF-8";
      LC_MEASUREMENT = "ja_JP.UTF-8";
      LC_MONETARY = "ja_JP.UTF-8";
      LC_NAME = "ja_JP.UTF-8";
      LC_NUMERIC = "ja_JP.UTF-8";
      LC_PAPER = "ja_JP.UTF-8";
      LC_TELEPHONE = "ja_JP.UTF-8";
      LC_TIME = "ja_JP.UTF-8";
    };
  };

  services.tailscale.enable = true;
  services.printing.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    dive
    podman-tui
    docker-compose
  ];

  users.users.${userInfo.username} = {
    isNormalUser = true;
    description = userInfo.username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  system.stateVersion = "24.05";

  # Input method configuration
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      fcitx5-skk
    ];
    fcitx5.waylandFrontend = true;
    fcitx5.settings.globalOptions = (import ./fcitx.nix);
  };
  # https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
  environment.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    QT_IM_MODULE = "fcitx";
    QT_IM_MODULES = "wayland;fcitx";
  };

  # Wake on LAN
  networking.interfaces.enp2s0.wakeOnLan.enable = true;

  # Audio configuration with PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Desktop environments
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    enableHidpi = true;
  };

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  services.desktopManager.plasma6.enable = true;
  programs.hyprland.enable = true;

  # Flatpak support
  services.flatpak.enable = true;
  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  # Font configuration
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      source-han-sans-vf-ttf
      sarasa-gothic
      plemoljp
      plemoljp-nf
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
    ];
    enableDefaultPackages = false;
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = [
          "Noto Serif CJK JP"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Source Han Sans VF"
          "Noto Color Emoji"
        ];
        monospace = [
          "Sarasa Mono J SemiBold"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
