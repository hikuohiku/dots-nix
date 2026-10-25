{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.mymodule.apps.core.enable {
    home.packages =
      (with pkgs; [
        # ========== Language Environment ==========
        nil
        nixfmt
        nixd
      ])
      # cargo や uv は macOS では brew(./darwin.nix) で導入する。
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux (
        with pkgs;
        [
          cargo
          uv
          wl-clipboard # clipboard
          openssl # ssl
          libnotify # norify-send
        ]
      );
  };
}
