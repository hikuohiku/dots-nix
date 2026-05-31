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
      inputs.vicinae.homeManagerModules.default
      ./apps.nix
      inputs.catppuccin.homeModules.catppuccin
      inputs.dms.homeModules.dank-material-shell
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
