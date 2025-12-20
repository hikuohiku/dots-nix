{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pavucontrol # PulseAudio GUI
    nautilus # file manager
    mission-center

    # social
    slack
    teams-for-linux
    discord

    # media player
    vlc

    # flatpak https://wiki.nixos.org/wiki/Flatpak
    flatpak
    gnome-software
  ];
}
