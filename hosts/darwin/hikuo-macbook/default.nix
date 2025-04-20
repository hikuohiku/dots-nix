{ self, pkgs, ... }:
{
  imports = [
    ../../../modules/darwin/fonts.nix
    ../../../modules/darwin/gui-tools.nix
    ../../../modules/darwin/browser.nix
    ../../../modules/darwin/editor.nix
    ../../../modules/darwin/tailscale.nix
    ../../../modules/darwin/karabiner.nix
    ../../../modules/darwin/yabai.nix
    ../../../modules/darwin/misc.nix
    ../../../modules/darwin/touchId.nix
    ../../../modules/darwin/vpn.nix
  ];

  users.knownUsers = [ "hikuo" ];
  users.users.hikuo.uid = 501;
  users.users.hikuo.shell = pkgs.fish;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
  ];

  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;
  system.configurationRevision = null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.enable = false;
}
