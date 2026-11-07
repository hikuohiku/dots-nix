{ config, lib, pkgs, upstream, ... }:
let
  apple-color-emoji = pkgs.runCommandLocal "apple-color-emoji-${upstream.apple-emoji.version}" { } ''
    install -Dm444 ${upstream.apple-emoji.src} $out/share/fonts/truetype/AppleColorEmoji.ttf
  '';
in
{
  config = lib.mkIf config.mymodule.apps.fonts.enable {
    fonts = {
      packages = with pkgs; [
        noto-fonts-cjk-serif
        source-han-sans-vf-ttf
        sarasa-gothic
        plemoljp
        plemoljp-nf
        apple-color-emoji
        noto-fonts-color-emoji
        nerd-fonts.symbols-only
      ];
      enableDefaultPackages = false;
      fontDir.enable = true;
      fontconfig = {
        # Notion などは "-apple-system, ..., Apple Color Emoji, Arial, sans-serif" と指定する。
        # Firefox 系は先頭から実在するフォントを使うため、Apple Color Emoji で英数字が描かれ、
        # 空白が全角幅に、数字が空白になる。前に並ぶ macOS・Windows のフォント名を sans-serif に向ける。
        localConf = ''
          <fontconfig>
          ${lib.concatMapStrings (family: ''
            <alias binding="same">
              <family>${family}</family>
              <prefer><family>sans-serif</family></prefer>
            </alias>
          '') [ "-apple-system" "BlinkMacSystemFont" "Segoe UI" ]}
          </fontconfig>
        '';
        defaultFonts = {
          serif = [
            "Noto Serif CJK JP"
            "Apple Color Emoji"
          ];
          sansSerif = [
            "Source Han Sans VF"
            "Apple Color Emoji"
          ];
          monospace = [
            "Sarasa Mono J SemiBold"
            "Apple Color Emoji"
          ];
          emoji = [
            "Apple Color Emoji"
            "Noto Color Emoji"
          ];
        };
      };
    };
  };
}