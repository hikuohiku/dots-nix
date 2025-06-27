{ withSystem, inputs, ... }:
{
  flake.nixosConfigurations.hikuo-laptop = withSystem "x86_64-linux" (
    ctx@{ inputs', ... }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs inputs';
        userInfo = {
          username = "hikuo";
        };
        systemInfo = {
          hostname = "hikuo-laptop";
        };
      };
      modules = [
        ./nixos/hikuo-laptop/configuration.nix
        ./nixos/hikuo-laptop/distributed-builds.nix
        inputs.nixos-hardware.nixosModules.microsoft-surface-laptop-amd
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.hikuo = import ./home/hikuo-laptop;
          home-manager.backupFileExtension = "backup";

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
