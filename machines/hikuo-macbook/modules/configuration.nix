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
      ../../../modules-2/home.nix
      ./apps.nix
    ];
  };

  home-manager.extraSpecialArgs = {
    inherit inputs inputs';
    mylib = inputs.my.lib;
    userInfo = {
      username = "hikuo";
      wallpaperPath = "/Users/hikuo/Pictures/wallpaper.jpg";
    };
  };
}
