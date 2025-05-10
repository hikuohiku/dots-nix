{
  inputs',
  pkgs,
  userInfo,
  ...
}:
{
  imports = [ ./icon.nix ];

  home.packages = [
    inputs'.aylur.packages.default
    pkgs.hyprshot
  ];

  gtk.enable = true;

  catppuccin = {
    enable = false;
    flavor = "latte";
    starship.enable = true;
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = userInfo.wallpaperPath;
      wallpaper = [ ",${userInfo.wallpaperPath}" ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs'.hyprland.packages.hyprland;
    settings = import ./hyprland.nix { inherit pkgs; };
    # https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
    systemd.variables = [ "--all" ];
  };
}
