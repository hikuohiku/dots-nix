{
  config,
  lib,
  pkgs,
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
      home.packages = [
        pkgs.bitwarden-cli
        pkgs.bws
      ];
    })

    (lib.mkIf (enabled cfg.recording) {
      home.packages = [ pkgs.vhs ];
    })
  ];
}
