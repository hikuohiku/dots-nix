{ config, lib, pkgs, ... }:
{
  # 公式の配布は npm パッケージだけ。開発プレビューで互換性の無い変更が続くため、
  # 起動のたびに npx で最新版を取る。
  config = lib.mkIf (config.mymodule.apps.dsh.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "dsh";
        runtimeInputs = [ pkgs.nodejs ];
        text = ''exec npx --yes @deepseek-ai/dsh@latest "$@"'';
      })
    ];
  };
}
