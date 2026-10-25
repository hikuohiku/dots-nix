{ config, lib, pkgs, upstream, ... }:
let
  cfg = config.mymodule.apps.yabai;
  # macOS 27 に対応した Christian-SC26/yabai フォークの notarize 済みバイナリを使う。
  yabaiPkg = pkgs.runCommand "yabai-${upstream.yabai.version}" { } ''
    install -Dm755 ${upstream.yabai.src} $out/bin/yabai
  '';
  yabaiWrapper = pkgs.writeShellScriptBin "yabai" ''
    exec /run/current-system/sw/bin/yabai "$@"
  '';
in
{
  disabledModules = [
    "services/yabai"
  ];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ yabaiPkg ];

    launchd.user.agents.yabai = lib.mkIf cfg.enableService {
      serviceConfig.ProgramArguments = [ "${yabaiWrapper}/bin/yabai" ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
      serviceConfig.EnvironmentVariables = {
        PATH = "${yabaiWrapper}/bin:${config.environment.systemPath}";
      };
    };

    launchd.daemons.yabai-sa = lib.mkIf cfg.enableService {
      script = "${yabaiWrapper}/bin/yabai --load-sa";
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive.SuccessfulExit = false;
    };

    environment.etc."sudoers.d/yabai".source = pkgs.runCommand "sudoers-yabai" { } ''
      YABAI_BIN="${yabaiPkg}/bin/yabai"
      SHASUM=$(sha256sum "$YABAI_BIN" | cut -d' ' -f1)
      cat <<EOF >"$out"
      %admin ALL=(root) NOPASSWD: sha256:$SHASUM /run/current-system/sw/bin/yabai --load-sa
      EOF
    '';
  };
}
