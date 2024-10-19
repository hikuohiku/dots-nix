{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tree
    fastfetch
    gomi # trash
    bitwarden-cli
    vhs # terminal screen capture
    rlwrap # readline wrapper

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
    xsv
    yq
    jwt-cli
    jq
    jnv

    # ========== TUI TOOL ========== 
    btop # resource monitor
    ranger # file manager
    lazydocker
  ];

  programs = {
    bat.enable = true;
    eza = {
      enable = true;
      enableFishIntegration = false;
    };
    fzf = {
      enable = true;
      enableFishIntegration = false;
      defaultOptions = [
        "--cycle"
        "--layout=reverse"
        "--border"
        "--height=90%"
        "--preview-window=wrap"
        ''--marker="*"''
      ];
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
