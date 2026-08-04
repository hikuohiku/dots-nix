{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.herdr;
in
{
  config = lib.mkIf cfg.enable {
    # Linux は nixpkgs から、macOS は brew(./darwin.nix) で導入する。
    # macOS 側で nixpkgs 版も入れると brew と二重導入になるため isLinux で絞る
    # (machines の apps.nix は darwin と home-manager の両スコープに import される)。
    home.packages = lib.optional pkgs.stdenv.isLinux pkgs.herdr;
  };
}
