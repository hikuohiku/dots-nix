{
  config,
  inputs,
  lib,
  pkgs,
  userInfo,
  ...
}:
{
  home.username = userInfo.username;
  home.homeDirectory = lib.mkForce "/home/${userInfo.username}";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    XDG_CONFIG_HOME = "/home/${userInfo.username}/.config";
  };

  xdg.mimeApps.enable = true;

  # voicist/prototype の Makefile / .agents/agent-team.mk をタスクランナーとして回すため。
  # make は dev shell (nix develop/devenv) 内では stdenv 経由で入るが、shell 外では
  # 入らない。buf は post-change が protobuf/ の変更時に要求する。
  home.packages = with pkgs; [
    helvum
    gnumake
    buf
  ];

  home.file.".zen/s6z0hpzf.default/user.js".source = ./zen-user.js;
  home.file.".zen/s6z0hpzf.default/chrome/userChrome.css".source = ./zen-userChrome.css;

  programs.dank-material-shell.plugins.aiQuotas.src = inputs.dms-ai-quotas;

  # Chrome の --app で開く Notion。ファイル名をウィンドウの app_id に揃えると、
  # タスクバーにこの名前とアイコンが出る。
  xdg.desktopEntries."chrome-www.notion.so__login-Default" = {
    name = "Notion";
    exec = "google-chrome-stable --app=https://www.notion.so/login";
    icon = "${./notion.png}";
    categories = [ "Office" ];
    settings.StartupWMClass = "chrome-www.notion.so__login-Default";
  };

  home.stateVersion = "24.05";
  home.enableNixpkgsReleaseCheck = false;

  # GlobalShortcuts portal が voim を app ID（jp.voim.Voim）で識別するために配置する。
  # ショートカットを割り当てる gnome-control-center の「アプリケーション」画面で一覧に表示させるため、NoDisplay は設定しない。
  xdg.desktopEntries."jp.voim.Voim" = {
    name = "Voim";
    exec = "${config.home.homeDirectory}/ghq/github.com/voicist/beta-frontend-linux/target/debug/voim run";
  };
  # voicist/beta-frontend-linux の常駐プロセス。Engine をチェックアウト先の .engine/ から探索するため、
  # チェックアウト先でビルドしたバイナリを直接起動する（設定内容はリポジトリの README に準拠）。
  systemd.user.services.voim = {
    Unit = {
      Description = "voim";
      PartOf = [ "graphical-session.target" ];
      After = [
        "graphical-session.target"
        "pipewire.service"
      ];
    };
    Service = {
      ExecStart = "%h/ghq/github.com/voicist/beta-frontend-linux/target/debug/voim run";
      # SIGTERM を voim だけに送り、voim が Engine を停止してから終了する。
      KillMode = "mixed";
      Restart = "no";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
