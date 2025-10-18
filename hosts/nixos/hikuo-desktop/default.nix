{
  pkgs,
  ...
}:
{
  imports = [
    ../../../modules/nixos/base
    ./hardware.nix # ハードウェア設定
    ./nvidia.nix # NVIDIA固有の設定
    ./remotebuild.nix
  ];

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
    fcitx5.settings.globalOptions = (import ../../../config/fcitx);
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
  programs.niri.enable = true;

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
      noto-fonts-emoji
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
