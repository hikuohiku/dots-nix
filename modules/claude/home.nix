{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.claude;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.claude-code ];

    # skills は実ファイルを別リポジトリ (dots-skills) で git 管理し、working-tree を指す
    # out-of-store symlink で貼る。中身を直接編集でき、新規 skill は rebuild 不要で反映される。
    home.file.".claude/skills".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/ghq/github.com/hikuohiku/dots-skills";
  };
}
