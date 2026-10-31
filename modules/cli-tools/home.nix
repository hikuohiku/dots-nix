{
  config,
  lib,
  pkgs,
  upstream,
  ...
}:
let
  cfg = config.mymodule.apps.cli-tools;
  enabled = category: cfg.enable || category.enable;
  # Linux のみパッケージを含めるヘルパー。macOS では nix 固有でないツールを brew(./darwin.nix) で導入する。
  linuxOnly = lib.optionals pkgs.stdenv.hostPlatform.isLinux;
in
{
  config = lib.mkMerge [
    (lib.mkIf (enabled cfg.base) {
      home.packages =
        with pkgs;
        [
          nix-output-monitor
        ]
        ++ linuxOnly [
          tree
          gomi
          gh
          ripgrep
          fd
          sd
          unzip
          wget
          httpie
          yq-go
          jq
          btop
          dive
          just
        ];

      home.sessionVariables.PAGER = "bat";
    })

    (lib.mkIf (enabled cfg.development) {
      home.packages =
        with pkgs;
        [
          devenv
          nixfmt
        ]
        ++ linuxOnly [
          tree-sitter
          treefmt
          # omp (oh-my-pi) の plugin install は bun 依存
          bun
          # npx で起動する MCP サーバー用
          nodejs
        ];

      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        rbenv.enable = pkgs.stdenv.hostPlatform.isLinux;
        fish.interactiveShellInit = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
          rbenv init - fish | source
        '';
      };
    })

    (lib.mkIf (enabled cfg.infrastructure) {
      home.packages =
        with pkgs;
        [
          cachix
        ]
        ++ linuxOnly [
          terraform
          kubectl
          kubernetes-helm
        ];
    })

    (lib.mkIf (enabled cfg.automation) {
      home.packages = linuxOnly (
        with pkgs;
        [
          ansible
          ansible-lint
        ]
      );
    })

    (lib.mkIf (enabled cfg.documents) {
      home.packages = linuxOnly [
        (pkgs.texlive.withPackages (
          ps: with ps; [
            latexindent
            chktex
          ]
        ))
      ];
    })

    (lib.mkIf (enabled cfg.secrets) {
      # bws は Bitwarden Secrets Manager 用 CLI（bitwarden-cli とは別物）。
      # macOS でも Homebrew に formula がなく、nixpkgs 版もキャッシュがなくソースビルドになるため、
      # 例外的に nix 側で上流の静的バイナリ（upstream.bws）を取得して導入する。
      home.packages = [
        (pkgs.runCommand "bws-${upstream.bws.version}" { nativeBuildInputs = [ pkgs.unzip ]; } ''
          unzip ${upstream.bws.src} bws
          install -Dm755 bws $out/bin/bws
        '')
      ]
      ++ linuxOnly [
        pkgs.bitwarden-cli
        pkgs.fnox
      ];

      # fnox.toml のあるディレクトリに入ると secret を読み込み、出ると外す
      programs.fish.interactiveShellInit = ''
        fnox activate fish | source
      '';
    })
  ];
}
