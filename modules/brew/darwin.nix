{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.brew.enable {
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
      "tinycast"
      "moonlight"
      "xcodes-app"
      "opencode-desktop"
    ];

    homebrew.masApps = {
      Bitwarden = 1352778147;
      Developer = 640199958;
    };

    homebrew.taps = [
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
      "hunk"
      # omp (oh-my-pi): pi fork のコーディングエージェント。tap の formula は
      # release バイナリを置くだけ。skills/CLAUDE.md/plugin は ~/.claude を
      # そのまま読むので nix 側の設定は不要。
      "omp"
      "anomalyco/tap/opencode"
      "jianshuo/tap/ccglass"
      "rjyo/moshi/moshi-hook"
    ];
  };
}
