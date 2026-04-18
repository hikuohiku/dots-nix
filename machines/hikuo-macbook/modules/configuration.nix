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
    ];
  };

  home-manager.extraSpecialArgs = {
    inherit inputs inputs';
    userInfo = {
      username = "hikuo";
      wallpaperPath = "/Users/hikuo/Pictures/wallpaper.jpg";
    };
  };
}
