{
  config,
  lib,
  ...
}:
let
  cfg = config.mymodule.apps.claude;
  dotsSkills = "${config.home.homeDirectory}/ghq/github.com/hikuohiku/dots-skills";
in
{
  config = lib.mkIf cfg.enable {
    # 公式ネイティブ版を入れ、更新は Claude Code 自身の自動アップデートに任せる。
    mymodule.nativeInstall.claude-code = {
      binary = "claude";
      install = "curl -fsSL https://claude.ai/install.sh | bash";
    };

    # skills は dots-skills/skills の working-tree を指す out-of-store symlink で貼る。
    home.file.".claude/skills".source = config.lib.file.mkOutOfStoreSymlink "${dotsSkills}/skills";

    # グローバル指示は dots-skills/AGENTS.md を単一ソースにして CLAUDE.md として参照
    # （Codex とも共有。modules/codex/home.nix が同じ AGENTS.md を ~/.codex/AGENTS.md へ貼る）
    home.file.".claude/CLAUDE.md".source =
      config.lib.file.mkOutOfStoreSymlink "${dotsSkills}/AGENTS.md";

    # statusline: stdin の JSON から model / cwd / git branch を 1 行目に、
    # context・セッション(5h)・週次リミットの使用率ゲージとコストを 2 行目に表示する。
    # settings.json に "statusLine": { "command": "~/.claude/statusline.sh" } を手書きで
    # 追記して有効化する（settings.json は nix 管理外）。スクリプト本体は再現性のため in-store symlink。
    home.file.".claude/statusline.sh" = {
      source = ./statusline.sh;
      executable = true;
    };
  };
}
