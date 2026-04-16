{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # nix
    nix-output-monitor

    devenv

    tree
    fastfetch
    gomi # trash
    bitwarden-cli # いつからかビルドできなくなったので使いたくなる時までは一旦コメントアウトしておく
    vhs # terminal screen capture
    rlwrap # readline wrapper
    gh

    # rust replacements
    ripgrep # grep
    fd # find
    sd # sed

    # archive
    unar # unarchiver
    unzip
    p7zip # 7z

    # http
    wget
    httpie

    # analyze data format
    yq-go
    jwt-cli
    jq
    jnv

    # tree-sitter
    tree-sitter

    ansible
    ansible-lint

    # ========== TUI TOOL ==========
    btop # resource monitor
    ranger # file manager
    lazydocker
    dive
    just

    terraform
    kubernetes-helm
    cachix
    doppler
    treefmt
    nixfmt
    yamlfmt
    (texlive.withPackages (
      ps: with ps; [
        latexindent
        chktex
      ]
    ))
  ];

  # bat, eza, fzf: Migrated to modules-2
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    rbenv.enable = true;
  };

  home.sessionVariables = {
    PAGER = "bat";
  };
}
