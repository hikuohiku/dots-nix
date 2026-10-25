{ config, lib, ... }:
let
  cfg = config.mymodule.apps.cli-tools;
  enabled = category: cfg.enable || category.enable;
in
{
  config = lib.mkMerge [
    (lib.mkIf (enabled cfg.base) {
      homebrew.brews = [
        "tree"
        "gomi"
        "gh"
        "ripgrep"
        "fd"
        "sd"
        "unzip"
        "wget"
        "httpie"
        "yq"
        "jq"
        "btop"
        "dive"
        "just"
      ];
    })

    (lib.mkIf (enabled cfg.development) {
      homebrew.brews = [
        "tree-sitter-cli"
        "treefmt"
        "bun"
        "rbenv"
      ];
    })

    (lib.mkIf (enabled cfg.infrastructure) {
      homebrew.taps = [ "hashicorp/tap" ];
      homebrew.brews = [
        "hashicorp/tap/terraform"
        "helm"
      ];
    })

    (lib.mkIf (enabled cfg.automation) {
      homebrew.brews = [
        "ansible"
        "ansible-lint"
      ];
    })

    (lib.mkIf (enabled cfg.documents) {
      homebrew.brews = [ "texlive" ];
    })

    (lib.mkIf (enabled cfg.secrets) {
      homebrew.brews = [
        "bitwarden-cli"
        "fnox"
      ];
    })
  ];
}
