{ config, lib, pkgs, ... }:
let
  zedIconAlias = pkgs.runCommand "zed-icon-alias" { } ''
    for size in 512x512 512x512@2; do
      src="${pkgs.zed-editor}/share/icons/hicolor/$size/apps/zed.png"
      if [ -f "$src" ]; then
        mkdir -p "$out/share/icons/hicolor/$size/apps"
        ln -s "$src" "$out/share/icons/hicolor/$size/apps/dev.zed.Zed.png"
      fi
    done
  '';
in
{
  config = lib.mkIf config.mymodule.apps.zed.enable {
    environment.systemPackages = [ pkgs.zed-editor zedIconAlias ];
  };
}
