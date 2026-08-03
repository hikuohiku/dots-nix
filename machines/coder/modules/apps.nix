{
  inputs,
  pkgs,
  ...
}:
{
  mymodule.apps.claude.enable = true;
  mymodule.apps.codex.enable = true;
  mymodule.apps.cli-tools.base.enable = true;
  mymodule.apps.cli-tools.development.enable = true;
  mymodule.apps.cli-tools.infrastructure.enable = true;
  mymodule.apps.core.enable = true;
  mymodule.apps.eza.enable = true;
  mymodule.apps.fish.enable = true;
  mymodule.apps.fzf.enable = true;
  mymodule.apps.git.enable = true;
  mymodule.apps.lazygit.enable = true;
  mymodule.apps.neovim.enable = true;

  home.packages = [
    pkgs.code-server
    pkgs.nix
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
