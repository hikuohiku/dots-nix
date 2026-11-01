{ config, lib, pkgs, ... }:
{
  # 公式の配布は npm パッケージだけ。開発プレビューで互換性の無い変更が続くため、
  # 起動のたびに npx で最新版を取る。
  # Nix ビルドの node だと dsh のネイティブアドオンが node 内部を読めず落ちるため
  # (deepseek-ai/deepseek-harness#1873)、npm の node パッケージで公式ビルドの node を
  # 一緒に取り、dsh をそれで動かす。公式バイナリは nix-ld で動く。
  config = lib.mkIf (config.mymodule.apps.dsh.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "dsh";
        runtimeInputs = [ pkgs.nodejs ];
        text = ''
          exec npx --yes --package node@24 --package @deepseek-ai/dsh@latest -- dsh "$@"
        '';
      })
    ];
  };
}
