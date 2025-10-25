{ pkgs, config, ... }:
let
  yabaiWrapper = pkgs.writeShellScriptBin "yabai" ''
    exec /run/current-system/sw/bin/yabai "$@"
  '';
in
{
  disabledModules = [
    "services/yabai"
  ];

  environment.systemPackages = with pkgs; [
    yabai
  ];

  launchd.user.agents.yabai = {
    serviceConfig.ProgramArguments = [
      "${yabaiWrapper}/bin/yabai"
    ];

    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
    serviceConfig.EnvironmentVariables = {
      PATH = "${yabaiWrapper}/bin:${config.environment.systemPath}";
    };
  };

  launchd.daemons.yabai-sa = {
    script = "${yabaiWrapper}/bin/yabai --load-sa";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive.SuccessfulExit = false;
  };

  environment.etc."sudoers.d/yabai".source = pkgs.runCommand "sudoers-yabai" { } ''
    YABAI_BIN="${yabaiWrapper}/bin/yabai"
    SHASUM=$(sha256sum "$YABAI_BIN" | cut -d' ' -f1)
    cat <<EOF >"$out"
    %admin ALL=(root) NOPASSWD: sha256:$SHASUM $YABAI_BIN --load-sa
    EOF
  '';
}
