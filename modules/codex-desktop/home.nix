{
  config,
  lib,
  pkgs,
  inputs',
  ...
}:
let
  cfg = config.mymodule.apps.codex-desktop;
in
{
  # Linux 専用パッケージ (machines の apps.nix は darwin スコープにも import されるため
  # isLinux で絞る)。
  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [ inputs'.codex-desktop-linux.packages.default ];
  };
}
