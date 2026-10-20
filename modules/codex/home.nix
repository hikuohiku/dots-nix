{ config, lib, ... }:
let
  cfg = config.mymodule.apps.codex;
  dotsSkills = "${config.home.homeDirectory}/ghq/github.com/hikuohiku/dots-skills";
in
{
  config = lib.mkIf cfg.enable {
    # 公式スタンドアロン版を入れ、更新は Codex 自身のアップデート（TUI から同じインストーラを
    # 再実行する）に任せる。
    mymodule.nativeInstall.codex = {
      binary = "codex";
      install = "curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh";
    };

    # 個人スキルは ~/.agents/skills から読み込まれる。
    # .codex/skills は Codex が組み込みスキルを書き込むため管理しない。

    # 共通グローバル指示
    home.file.".codex/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${dotsSkills}/AGENTS.md";
  };
}
