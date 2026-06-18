{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.sunshine.enable {
    services.sunshine = {
      enable = true;
      openFirewall = true;
      autoStart = true;
      # 設定は home-manager で配置する生の sunshine.conf（modules/sunshine/sunshine.conf）で
      # 決め打ちする。services.sunshine.settings は使わない（nix 生成層を避ける方針）。
      # キャプチャは wlr (Wayland screencopy) で動くため capSysAdmin(KMS 用) は不要。

      # NVENC (GPU エンコード) を使うため CUDA 付きでローカルビルドする。
      # nixpkgs 既定の sunshine は cudaSupport=false で software エンコードのみ。
      package = pkgs.sunshine.override {
        cudaSupport = true;
        cudaPackages = pkgs.cudaPackages;
      };
    };
  };
}
