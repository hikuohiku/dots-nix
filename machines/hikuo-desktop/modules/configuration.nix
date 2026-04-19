{
  inputs,
  inputs',
  ...
}:
{
  imports = [
    ./host.nix
    ./apps.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.hikuo = {
    imports = [
      ./home.nix
      inputs.my.homeManagerModules.default
      ./apps.nix
      inputs.catppuccin.homeManagerModules.catppuccin
    ];
  };

  home-manager.extraSpecialArgs = {
    inherit inputs inputs';
    userInfo = {
      username = "hikuo";
      wallpaperPath = "/home/hikuo/Pictures/wallpaper.jpg";
      git = {
        username = "hikuohiku";
        email = "hikuohiku@gmail.com";
      };
    };
  };
}
