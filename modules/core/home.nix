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

    # ~/Downloads を /tmp への symlink にし、再起動で掃除させる。
    # 既存の実ディレクトリは退避する（macOS は削除拒否の ACL を外してから）。
    home.activation.downloadsToTmp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      dl="$HOME/Downloads"
      if [ ! -L "$dl" ]; then
        if [ -e "$dl" ]; then
          ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''run /bin/chmod -N "$dl"''}
          run mv "$dl" "$dl.bak.$(date +%Y%m%d%H%M%S)"
        fi
        run ln -s /tmp "$dl"
      fi
    '';
  };
}
