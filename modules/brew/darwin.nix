{ config, lib, ... }:
let
  user = config.system.primaryUser;
in
{
  config = lib.mkIf config.mymodule.apps.brew.enable {
    # 未設定時のみ brew autoupdate を開始し、launchd による毎日の自動更新を有効化する。
    # 既存設定があるとオプション変更が反映されないため、変更時は `brew autoupdate delete` 後に switch し直す。
    system.activationScripts.postActivation.text = lib.mkAfter ''
      if sudo --user=${user} --set-home /opt/homebrew/bin/brew autoupdate status | grep -q "not configured"; then
        sudo --user=${user} --set-home /opt/homebrew/bin/brew autoupdate start 1d --upgrade --cleanup --notify-on-error
      fi
    '';

    homebrew.casks = [
      "google-chrome"
      "google-gemini"
      "orbstack"
      "notion"
      "slack"
      "discord"
      "chatgpt"
      "claude"
      "antigravity"
      "typeless"
      "tailscale-app"
      "cloudflare-warp"
      "notchnook"
      "openusage"
      "abue-ammar/tinycast/tinycast"
      "moonlight"
      "xcodes-app"
      "opencode-desktop"
    ];

    homebrew.masApps = {
      Bitwarden = 1352778147;
      Developer = 640199958;
    };

    homebrew.taps = [
      "homebrew/autoupdate"
      "modem-dev/tap"
      "can1357/tap"
      "anomalyco/tap"
      "jianshuo/tap"
      "rjyo/moshi"
      "abue-ammar/tinycast"
    ];

    homebrew.brews = [
      "ghcup"
      "swiftly"
      "xcodes"
      "aria2"
      "mint"
      "fastlane"
      "swift-protobuf"
      "protoc-gen-grpc-swift"
      "buf"
      "ffmpeg"
      "k6"
      "modem-dev/tap/hunk"
      # omp (oh-my-pi): pi fork のコーディングエージェント。tap の formula は
      # release バイナリを置くだけ。skills/CLAUDE.md/plugin は ~/.claude を
      # そのまま読むので nix 側の設定は不要。
      "can1357/tap/omp"
      "anomalyco/tap/opencode"
      "jianshuo/tap/ccglass"
      "rjyo/moshi/moshi-hook"
    ];
  };
}
