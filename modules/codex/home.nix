{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.codex;
  dotsSkills = "${config.home.homeDirectory}/ghq/github.com/hikuohiku/dots-skills";
in
{
  config = lib.mkIf cfg.enable {
    # Codex 本体。Linux は nixpkgs から、macOS は brew(modules/brew/darwin.nix) で導入。
    home.packages = lib.optional pkgs.stdenv.isLinux pkgs.codex;

    # スキルは Claude と同じ dots-skills working-tree を指す（単一ソース）。
    # Codex 組み込みの .system/ はこの配下に再生成され、dots-skills 側 .gitignore で除外。
    home.file.".codex/skills".source = config.lib.file.mkOutOfStoreSymlink dotsSkills;

    # 共通グローバル指示
    home.file.".codex/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${dotsSkills}/AGENTS.md";
  };
}
