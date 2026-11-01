{ config, lib, pkgs, ... }:
{
  # 公式の配布は npm パッケージだけ。開発プレビューで互換性の無い変更が続くため、
  # 起動のたびに npx で最新版を取る。
  # Nix ビルドの node だと dsh のネイティブアドオンが内部 API を見つけられず落ちるため、
  # --expose-internals 付きで起動する（deepseek-ai/deepseek-harness#1873）。
  config = lib.mkIf (config.mymodule.apps.dsh.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "dsh";
        runtimeInputs = [ pkgs.nodejs ];
        # 内側の sh で展開させるため、意図して単引用符で渡す。
        excludeShellChecks = [ "SC2016" ];
        text = ''
          exec npx --yes --package @deepseek-ai/dsh@latest -- \
            sh -c 'exec node --expose-internals "$(readlink -f "$(command -v dsh)")" "$@"' dsh "$@"
        '';
      })
    ];
  };
}
