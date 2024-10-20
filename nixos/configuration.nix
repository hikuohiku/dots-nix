# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  # config,
  pkgs,
  userInfo,
  ...
}:
let
  locale = "ja_JP.UTF-8";
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # nix
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # nix-ld
  programs.nix-ld.enable = true;

  # hostname
  networking.hostName = userInfo.hostname;

  # environment variables
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # kernel module params
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ]; # https://wiki.hyprland.org/Nvidia/#suspendwakeup-issues
  boot.extraModprobeConfig = ''
    options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3"
  ''; # https://wiki.hyprland.org/Nvidia/#fixing-other-random-flickering-nuclear-method

  # time zone
  time.timeZone = "Asia/Tokyo";

  # i18n
  i18n = {
    defaultLocale = locale;
    extraLocaleSettings = {
      LC_ADDRESS = locale;
      LC_IDENTIFICATION = locale;
      LC_MEASUREMENT = locale;
      LC_MONETARY = locale;
      LC_NAME = locale;
      LC_NUMERIC = locale;
      LC_PAPER = locale;
      LC_TELEPHONE = locale;
      LC_TIME = locale;
    };
  };
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      fcitx5-skk
    ];
    fcitx5.waylandFrontend = true;
  };
  # https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
  environment.sessionVariables.XMODIFIERS = "@im=fcitx";
  environment.sessionVariables.QT_IM_MODULE = "fcitx";
  environment.sessionVariables.QT_IM_MODULES = "wayland;fcitx";

  # nvidia
  # https://wiki.nixos.org/wiki/Nvidia
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true; # https://wiki.hyprland.org/Nvidia/#suspendwakeup-issues
    # powerManagement.finegrained = true; # experimental
    open = false;
    nvidiaSettings = true;
  };

  # networking
  networking.networkmanager.enable = true;

  # tailscale
  services.tailscale.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # docker
  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  # desktop environments
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    enableHidpi = true;
  };

  services.xserver.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.desktopManager.plasma6.enable = true;

  programs.hyprland.enable = true;

  # flatpak
  # https://wiki.nixos.org/wiki/Flatpak
  services.flatpak.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "gtk";

  # font
  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-serif
      source-han-sans-vf-ttf
      sarasa-gothic
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userInfo.username} = {
    isNormalUser = true;
    description = userInfo.username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
