{
  lib,
  config,
  pkgs,
  userInfo,
  ...
}:
{
  # home-manager
  home.username = userInfo.username;
  home.homeDirectory = lib.mkForce "/Users/${userInfo.username}";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # `nh darwin switch` で適用する（Claude は NOPASSWD の darwin-rebuild を引き続き使う）。
  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/ghq/github.com/hikuohiku/dots-nix/machines/hikuo-macbook";
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
}
