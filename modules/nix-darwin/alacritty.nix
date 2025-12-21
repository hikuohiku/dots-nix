{ inputs, ... }:
{
  homebrew.casks = [
    "alacritty"
  ];

  home-manager.users.hikuo = {
    imports = with inputs.my.homeManagerModules; [
      alacritty
    ];
  };
}
