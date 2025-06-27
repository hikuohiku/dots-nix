{ withSystem, inputs, ... }:
{
  flake.nixosConfigurations.hikuo-desktop = withSystem "x86_64-linux" (
    ctx@{ inputs', ... }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs inputs';
        userInfo = {
          username = "hikuo";
        };
        systemInfo = {
          hostname = "hikuo-desktop";
        };
      };
      modules = [
        ./nixos/hikuo-desktop
        inputs.catppuccin.nixosModules.catppuccin
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.hikuo = import ./home/hikuo-desktop;
          home-manager.backupFileExtension = "backup";
          home-manager.sharedModules = [
            inputs.catppuccin.homeManagerModules.catppuccin
          ];

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
      ];
    }
  );
}
