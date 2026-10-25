{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.mymodule.nativeInstall;
  binDir = "${config.home.homeDirectory}/.local/bin";
in
{
  # 自己更新する公式ネイティブインストーラで入れるアプリ。nix は「無ければインストール」だけを
  # 担い、以後の更新はアプリ自身に任せる。バイナリは ~/.local/bin に置かれる前提。
  options.mymodule.nativeInstall = lib.mkOption {
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          binary = lib.mkOption {
            type = lib.types.str;
            description = "インストール後に ~/.local/bin に置かれるバイナリ名";
          };
          install = lib.mkOption {
            type = lib.types.lines;
            description = "インストールコマンド（bash）";
          };
        };
      }
    );
  };

  config = lib.mkIf (cfg != { }) {
    home.sessionPath = [ binDir ];
    # fish は sessionPath より nix profile が前に来るため、明示的に先頭へ移す。
    xdg.configFile."fish/conf.d/native-install-path.fish".text =
      "fish_add_path --path --move ${lib.escapeShellArg binDir}";

    home.activation = lib.mapAttrs' (
      name: app:
      let
        binary = "${binDir}/${app.binary}";
        # インストーラが PATH 未設定と判断して rc ファイルを書き換えないよう binDir を含める。
        install = ''
          export PATH=${binDir}:${
            lib.makeBinPath [
              pkgs.bash
              pkgs.curl
              pkgs.coreutils
              pkgs.gnugrep
              pkgs.gnused
              pkgs.gnutar
              pkgs.gzip
              pkgs.findutils
              pkgs.gawk
              pkgs.perl # shasum (claude の install.sh が macOS で使う)
            ]
          }:$PATH
          ${app.install}
        '';
      in
      lib.nameValuePair "nativeInstall-${name}" (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -x ${lib.escapeShellArg binary} ]; then
            verboseEcho ${lib.escapeShellArg "Installing ${name}"}
            run ${lib.getExe pkgs.bash} -o pipefail -c ${lib.escapeShellArg install}
            if [[ ! -v DRY_RUN && ! -x ${lib.escapeShellArg binary} ]]; then
              echo ${lib.escapeShellArg "${name} installer did not create ${binary}"} >&2
              exit 1
            fi
          fi
        ''
      )
    ) cfg;
  };
}
