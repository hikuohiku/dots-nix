{ config, lib, ... }:
{
  config = lib.mkIf config.mymodule.apps.brew.enable {
    homebrew.casks = [
      "google-chrome"
      "google-chrome@canary"
      "firefox"
      "chromium"
      "orbstack"
      "obsidian"
      "notion"
      "slack"
      "discord"
      "chatgpt"
      "raycast"
      "inkscape"
      "zotero"
      "zed"
      "forklift"
      "insomnia"
      "tailscale-app"
      "core-tunnel"
      "notchnook"
      "launchcontrol"
      "xbar"
      "xcodes-app"
      "claude-code"
      "mactex"
      "wireshark"
      "puremac"
    ];

    homebrew.masApps = {
      Bitwarden = 1352778147;
      "Perplexity: Ask Anything" = 6714467650;
      "Hidden Bar" = 1452453066;
    };

    homebrew.brews = [
      "ghcup"
      "swiftly"
      "xcodes"
      "aria2"
      "mint"
      "fastlane"
      "swift-protobuf"
    ];
  };
}
