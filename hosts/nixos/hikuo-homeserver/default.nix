{
  modulesPath,
  pkgs,
  lib,
  ...
}:
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

  time.timeZone = "Asia/Tokyo";
  networking.hostName = "hikuo-homebase";
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
  services.tailscale.enable = true;

  programs.nix-ld.enable = true;

  systemd.services."moneyforward-automation" = {
    description = "Run Money Forward automation script";
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.uv}/bin/uv run main.py";
      User = "hikuo";
      Group = "users";
      WorkingDirectory = "/home/hikuo/moneyforward-automation";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  systemd.timers."moneyforward-automation" = {
    description = "Run Money Forward automation script daily at 12:00 PM";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 12:00:00";
      AccuracySec = "1h";
      Persistent = true;
      RandomizedDelaySec = "600";
      Unit = "moneyforward-automation.service";
    };
  };

  system.stateVersion = "25.05";
}
