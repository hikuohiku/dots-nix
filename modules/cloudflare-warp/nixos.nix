{ config, lib, ... }:
{
  # unfree かつ cache.nixos.org にバイナリはないが、上流の .deb を展開するだけでソースビルドは発生しないため nixpkgs のパッケージを利用する。
  # 組織への登録は warp-cli registration new <team> で行う。
  config = lib.mkIf config.mymodule.apps.cloudflare-warp.enable {
    services.cloudflare-warp.enable = true;
  };
}
