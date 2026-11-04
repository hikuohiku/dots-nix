{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.mymodule.apps.mise.enable && pkgs.stdenv.hostPlatform.isLinux) {
    home.packages = [ pkgs.mise ];

    # NixOS では既定で python などをソースからビルドするため、上流のバイナリを nix-ld で動かす。
    xdg.configFile."mise/config.toml".text = ''
      [settings]
      all_compile = false
    '';
  };
}
