{ inputs, inputs', ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.hikuo = {
    imports = [
      ./home.nix
      inputs.mylib.darwinModules.home
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
