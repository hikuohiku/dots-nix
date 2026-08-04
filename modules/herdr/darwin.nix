{ config, lib, ... }:
let
  cfg = config.mymodule.apps.herdr;
in
{
  # macOS は brew で導入する。nixpkgs 版は上流リリースより遅れるため、
  # 自己更新できる brew 側のバージョンを落とさない。
  config = lib.mkIf cfg.enable {
    homebrew.brews = [ "herdr" ];
  };
}
