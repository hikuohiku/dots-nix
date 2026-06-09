{ config, lib, pkgs, ... }:
let
  cfg = config.mymodule.apps.yabai;
  # nixpkgs の yabai は enableParallelBuilding = true だが、yabai の makefile は
  # `all: clean-build $(BINS)` で clean-build(rm -rf ./bin)と bin/yabai のビルド
  # (mkdir ./bin && clang -o bin/yabai)に順序依存が無い。-j 並列だと両者が同時実行
  # され `rm: cannot remove './bin': Operation not permitted` で落ちる(7.1.25 で踏んだ)。
  # 直列ビルド化して race を回避する。上流が makefile を直すまでの恒久 workaround。
  yabaiPkg = pkgs.yabai.overrideAttrs (_: {
    enableParallelBuilding = false;
  });
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
      YABAI_BIN="${yabaiWrapper}/bin/yabai"
      SHASUM=$(sha256sum "$YABAI_BIN" | cut -d' ' -f1)
      cat <<EOF >"$out"
      %admin ALL=(root) NOPASSWD: sha256:$SHASUM $YABAI_BIN --load-sa
      EOF
    '';
  };
}
