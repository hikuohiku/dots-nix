{ inputs, inputs', ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.hikuo = {
    imports = [
      ./home.nix
      inputs.my.darwinModules.home
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
