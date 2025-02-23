{
  pkgs,
  ...
}: {
  # kernel module params
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ]; # https://wiki.hyprland.org/Nvidia/#suspendwakeup-issueslibselibse
  boot.extraModprobeConfig = ''
    options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3"
  ''; # https://wiki.hyprland.org/Nvidia/#fixing-other-random-flickering-nuclear-method

  # nvidia driver configuration
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true; # https://wiki.hyprland.org/Nvidia/#suspendwakeup-issues
    # powerManagement.finegrained = true; # experimental
    open = false;
    nvidiaSettings = true;
  };

  # Container support
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.docker.package = pkgs.docker;
}