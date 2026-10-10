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
  # ~/.claude/skills の user レベル読み込みは omp 側で opt-in (skills.enableClaudeUser,
  # default false) のため、使う側で `omp config set skills.enableClaudeUser true` する。
  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [ inputs'.omp.packages."oh-my-pi-bin" ];
  };
}
