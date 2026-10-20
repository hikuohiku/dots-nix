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
in
{
  config = lib.mkMerge [
    (lib.mkIf (enabled cfg.base) {
      home.packages = with pkgs; [
        nix-output-monitor
        tree
        fastfetch
        gomi
        rlwrap
        gh
        ripgrep
        fd
        sd
        unar
        unzip
        p7zip
        wget
        httpie
        yq-go
        jwt-cli
        jq
        jnv
        btop
        ranger
        lazydocker
        dive
        just
      ];

      home.sessionVariables.PAGER = "bat";
    })

    (lib.mkIf (enabled cfg.development) {
      home.packages = with pkgs; [
        devenv
        tree-sitter
        treefmt
        nixfmt
        yamlfmt
        # omp (oh-my-pi) の plugin install は bun 依存
        bun
      ];

      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        rbenv.enable = true;
      };
    })

    (lib.mkIf (enabled cfg.infrastructure) {
      home.packages = with pkgs; [
        terraform
        kubernetes-helm
        cachix
        doppler
      ];
    })

    (lib.mkIf (enabled cfg.automation) {
      home.packages = with pkgs; [
        ansible
        ansible-lint
      ];
    })

    (lib.mkIf (enabled cfg.documents) {
      home.packages = [
        (pkgs.texlive.withPackages (
          ps: with ps; [
            latexindent
            chktex
          ]
        ))
      ];
    })

    (lib.mkIf (enabled cfg.secrets) {
      # bws は Secrets Manager 用 (unfree)。bitwarden-cli とは別物。
      # unfree で cache に無くソースビルドになるため、上流の静的バイナリを取得する。
      home.packages = [
        pkgs.bitwarden-cli
        (pkgs.runCommand "bws-${upstream.bws.version}" { nativeBuildInputs = [ pkgs.unzip ]; } ''
          unzip ${upstream.bws.src} bws
          install -Dm755 bws $out/bin/bws
        '')
      ];
    })

    (lib.mkIf (enabled cfg.recording) {
      home.packages = [ pkgs.vhs ];
    })
  ];
}
