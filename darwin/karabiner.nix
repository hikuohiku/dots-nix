{ ... }:
{
  # これ壊れてる https://github.com/LnL7/nix-darwin/issues/1041
  # # TODO: config も dotfiles 管理する
  # services.karabiner-elements.enable = true;

  homebrew.casks = [
    "karabiner-elements"
  ];
}
