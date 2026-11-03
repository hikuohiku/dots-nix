{ pkgs, ... }:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
in
{
  # 上流リリースのバイナリを取得する。バージョンとハッシュは sources.json で管理し、
  # update.sh（CI で定期実行）で最新に追従させる。
  _module.args.upstream = builtins.mapAttrs (
    _: s:
    let
      asset = s.assets.${pkgs.stdenv.hostPlatform.system};
      tag = s.tagPrefix + s.version;
    in
    {
      inherit (s) version;
      src = pkgs.fetchurl {
        url = "https://github.com/${s.repo}/releases/download/${tag}/${
          builtins.replaceStrings [ "{version}" ] [ s.version ] asset.name
        }";
        inherit (asset) hash;
      };
    }
  ) sources;
}
