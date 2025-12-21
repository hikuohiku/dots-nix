{
  withSystem,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.hikuo-laptop = withSystem "x86_64-linux" (
    { inputs', ... }:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.nixos-hardware.nixosModules.microsoft-surface-laptop-amd
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.hikuo = import ./modules/home;
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
      ]
      ++ builtins.attrValues (inputs.my.lib.mkModulesFromDir ./modules);

      specialArgs = {
        inherit inputs inputs';
        userInfo = {
          username = "hikuo";
        };
        systemInfo = {
          hostname = "hikuo-laptop";
        };
      };
    }
  );
}
