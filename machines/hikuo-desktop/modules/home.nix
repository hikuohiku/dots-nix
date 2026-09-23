{
  config,
  lib,
  pkgs,
  userInfo,
  ...
}:
let
  mkNativeInstall = import ../../../modules/native-install.nix { inherit lib pkgs; };
in
{
  home.username = userInfo.username;
  home.homeDirectory = lib.mkForce "/home/${userInfo.username}";
  programs.home-manager.enable = true;

  home.sessionPath = lib.optional config.mymodule.apps.claude.enable "${config.home.homeDirectory}/.local/bin";
  home.file.".config/fish/conf.d/claude-path.fish" = lib.mkIf config.mymodule.apps.claude.enable {
    text = "fish_add_path --path --move ${lib.escapeShellArg "${config.home.homeDirectory}/.local/bin"}";
  };
  home.activation = lib.mkIf config.mymodule.apps.claude.enable {
    installClaudeCode = mkNativeInstall {
      name = "Claude Code";
      binary = "${config.home.homeDirectory}/.local/bin/claude";
      install = ''
        export PATH=${
          lib.makeBinPath [
            pkgs.curl
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.gnused
          ]
        }:$PATH
        ${lib.getExe pkgs.curl} -fsSL https://claude.ai/install.sh | ${lib.getExe pkgs.bash}
      '';
    };
  };

  home.sessionVariables = {
    XDG_CONFIG_HOME = "/home/${userInfo.username}/.config";
  };

  xdg.mimeApps.enable = true;

  # voicist/prototype の Makefile / .agents/agent-team.mk をタスクランナーとして回すため。
  # make は dev shell (nix develop/devenv) 内では stdenv 経由で入るが、shell 外では
  # 入らない。buf は post-change が protobuf/ の変更時に要求する。
  home.packages = with pkgs; [
    gnumake
    buf
  ];

  programs.dank-material-shell = {
    enable = true;
  };

  home.stateVersion = "24.05";
  home.enableNixpkgsReleaseCheck = false;
}
