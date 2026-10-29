{
  config,
  pkgs,
  systemInfo,
  ...
}:
let
  repo = "${config.users.users.hikuo.home}/ghq/github.com/hikuohiku/dots-nix";
  machine = "machines/${systemInfo.hostname}";

  # flake 入力を更新し、ビルドが通れば flake.lock を main に push して次回起動の世代にする。
  # 作業中の checkout を巻き込まないよう、origin/main を専用 worktree に取り出して行う。
  autoUpdate = pkgs.writeShellApplication {
    name = "dots-nix-auto-update";
    runtimeInputs = [
      config.nix.package
      pkgs.git
      pkgs.coreutils
      pkgs.libnotify
    ];
    text = ''
      trap 'notify-send -u critical "dots-nix auto-update" "失敗しました: journalctl --user -u dots-nix-auto-update"' ERR

      wt="''${XDG_CACHE_HOME:-$HOME/.cache}/dots-nix-auto-update"
      git -C ${repo} fetch origin main
      if [ ! -e "$wt" ]; then
        git -C ${repo} worktree add --detach "$wt" origin/main
      fi
      git -C "$wt" checkout --detach --force origin/main

      cd "$wt/${machine}"
      nix flake update
      if git diff --quiet -- flake.lock; then
        echo "flake 入力に更新なし"
        exit 0
      fi

      # nixos-rebuild build は cwd に result を作るので、worktree の外で実行する。
      (cd "$(mktemp -d)" && /run/current-system/sw/bin/nixos-rebuild build --flake "$wt/${machine}")

      git commit -m "${systemInfo.hostname}: flake 入力を更新する" -- flake.lock
      git push origin HEAD:main

      # 使用中のセッション（niri, NVIDIA）を差し替えないよう switch ではなく boot にする。
      # sudoers の NOPASSWD はこのパスに限っている（claude-rebuild.nix）。
      /run/wrappers/bin/sudo /run/current-system/sw/bin/nixos-rebuild boot --flake "$wt/${machine}"
      notify-send "dots-nix auto-update" "flake 入力を更新しました。次回起動で反映されます"
    '';
  };
in
{
  systemd.user.services.dots-nix-auto-update = {
    description = "Update flake inputs and stage the next boot generation";
    unitConfig.ConditionUser = "hikuo";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${autoUpdate}/bin/dots-nix-auto-update";
    };
  };

  systemd.user.timers.dots-nix-auto-update = {
    wantedBy = [ "timers.target" ];
    unitConfig.ConditionUser = "hikuo";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true; # 電源オフで逃した分はログイン後に走らせる
      RandomizedDelaySec = "30m";
    };
  };
}
