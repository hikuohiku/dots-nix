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
        cargo
        uv
        nil
        nixfmt
        nixd
      ])
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux (
        with pkgs;
        [
          wl-clipboard # clipboard
          openssl # ssl
          libnotify # norify-send
        ]
      );
  };
}
