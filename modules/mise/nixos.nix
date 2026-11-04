{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.mise.enable {
    # mise が導入する dotnet の起動に必要な ICU を nix-ld のライブラリに追加する。
    programs.nix-ld.libraries = [ pkgs.icu ];
  };
}
