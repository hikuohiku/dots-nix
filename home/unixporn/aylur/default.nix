{
  inputs,
  pkgs,
  aylurpkgs,
  userInfo,
  ...
}:
{
  imports = [ ./icon.nix ];

  home.packages = with pkgs; [
    aylurpkgs.default
    hyprshot
  ];

  gtk.enable = true;

  catppuccin.enable = true;
  catppuccin.flavor = "latte";
  programs.starship.catppuccin.enable = true;

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
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    settings = import ./hyprland.nix { inherit pkgs; };
    plugins = [
      pkgs.hyprlandPlugins.hyprfocus
    ];
    # https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
    systemd.variables = [ "--all" ];
  };
}
