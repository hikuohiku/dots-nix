{ modulesPath, lib, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
    # Opinionated: disable channels
    channel.enable = false;
  };

  users.users.hikuo = {
    isNormalUser = true;
    initialHashedPassword = "$6$y.tuMBFQ5nXEZdI7$wgOsIjdguzJ2TXQ8kyPXkijXM3IM3AOv0eCZ2//RC92xkocsSRWaQ/84qkPBangYWqM82g9VkVxDWw/D3cyeT0";
    extraGroups = [ "wheel" ];
  };

  boot.loader.grub.enable = lib.mkDefault true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.growPartition = true;

  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  networking.hostName = "base";
  services.qemuGuest.enable = true;
  services.cloud-init.network.enable = true;
  # Desktop environments
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  services.desktopManager.plasma6.enable = true;

  programs.nix-ld.enable = true;
  system.stateVersion = "25.05";
}
