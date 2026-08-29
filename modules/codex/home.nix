{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.codex;
  dotsSkills = "${config.home.homeDirectory}/ghq/github.com/hikuohiku/dots-skills";
in
{
  config = lib.mkIf cfg.enable {
    # Codex 本体。Linux は nixpkgs から、macOS は brew(modules/brew/darwin.nix) で導入。
    home.packages = lib.optional pkgs.stdenv.isLinux pkgs.codex;

    # スキルは Claude と同じ dots-skills/skills の working-tree を指す。
    home.file.".codex/skills".source = config.lib.file.mkOutOfStoreSymlink
      "${dotsSkills}/skills";

    # 共通グローバル指示
    home.file.".codex/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${dotsSkills}/AGENTS.md";
  };
}
