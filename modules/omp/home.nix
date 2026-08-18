{
  config,
  lib,
  pkgs,
  inputs',
  ...
}:
let
  cfg = config.mymodule.apps.omp;
in
{
  # macOS は brew (modules/brew/darwin.nix) の can1357/tap で入れるため Linux のみ。
  # skills / CLAUDE.md / Claude プラグインは omp が ~/.claude を直接読むので設定は持たない。
  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [ inputs'.omp.packages.omp ];
  };
}
