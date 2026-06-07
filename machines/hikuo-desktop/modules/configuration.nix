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

  programs.niri.package = inputs'.niri-flake.packages.niri-unstable;

  catppuccin = {
    enable = true;
    autoEnable = false;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bak";
  home-manager.users.hikuo = {
    imports = [
      ./home.nix
      inputs.my.homeManagerModules.default
      inputs.vicinae.homeManagerModules.default
      ./apps.nix
      inputs.catppuccin.homeModules.catppuccin
      inputs.dms.homeModules.dank-material-shell
      inputs.dms.homeModules.niri
      ./niri.nix
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
