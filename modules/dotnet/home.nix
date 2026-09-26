{
  config,
  lib,
  pkgs,
  ...
}:
let
  # ponytail: 10.0.4xx を得るため dotnet だけ新しい nixpkgs から取る。
  # nixpkgs を更新したら pkgs.dotnetCorePackages.sdk_10_0 に戻す。
  pinned = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/74435dcdae840e9770652a7bf7754c2ef7b257e1.tar.gz";
    sha256 = "1ba5541s52i2jjhh15j3rmjvcc4hy9vmimnyqw2gzz825z0vfd91";
  }) { inherit (pkgs.stdenv.hostPlatform) system; };
  sdk = pinned.dotnetCorePackages.sdk_10_0;
in
{
  config = lib.mkIf config.mymodule.apps.dotnet.enable {
    home.packages = [ sdk ];

    home.sessionVariables = {
      DOTNET_ROOT = "${sdk}/share/dotnet";
      DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    };

    # dotnet tool install -g の配置先
    home.sessionPath = [ "${config.home.homeDirectory}/.dotnet/tools" ];
  };
}
