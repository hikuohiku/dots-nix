{
  pkgs,
  userInfo,
  systemInfo,
  ...
}:
{
  # Nix configuration
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable nix-ld
  programs.nix-ld.enable = true;

  # Basic system settings
  networking = {
    hostName = systemInfo.hostname;
    networkmanager.enable = true;
  };

  # Environment variables
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Bootloader configuration
  boot.loader = {
    grub = {
      enable = true;
      useOSProber = true;
      efiSupport = true;
      device = "nodev";
    };
    efi.canTouchEfiVariables = true;
  };

  # Time zone and locale settings
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

  # Basic services
  services = {
    tailscale.enable = true;
    printing.enable = true;
  };

  # Hardware configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Container support
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Development tools
  environment.systemPackages = with pkgs; [
    dive
    podman-tui
    docker-compose
  ];

  # User configuration
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

  # TODO: move to device specific
  # System state version
  system.stateVersion = "24.05";
}
