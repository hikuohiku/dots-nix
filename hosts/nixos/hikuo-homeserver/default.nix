{ ... }:
{

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
    };
    # Opinionated: disable channels
    channel.enable = false;
  };

  users.users.hikuo = {
    isNormalUser = true;
    initialHashedPassword = "$6$y.tuMBFQ5nXEZdI7$wgOsIjdguzJ2TXQ8kyPXkijXM3IM3AOv0eCZ2//RC92xkocsSRWaQ/84qkPBangYWqM82g9VkVxDWw/D3cyeT0";
    extraGroups = [ "wheel" ];
  };
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
}
