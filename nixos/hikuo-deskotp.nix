{
  pkgs,
  ...
}:
{
  # kernel module params
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ]; # https://wiki.hyprland.org/Nvidia/#suspendwakeup-issues
  boot.extraModprobeConfig = ''
    options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3"
  ''; # https://wiki.hyprland.org/Nvidia/#fixing-other-random-flickering-nuclear-method

  # wake on lan
  networking.interfaces.enp2s0.wakeOnLan.enable = true;

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      fcitx5-skk
    ];
    fcitx5.waylandFrontend = true;
    fcitx5.settings.globalOptions = (import ./hikuo-desktop/fcitx-conf.nix);
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
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.docker.package = pkgs.docker;
 
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
}
