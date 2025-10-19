{
  withSystem,
  inputs,
  lib,
  ...
}:
{
  flake.darwinConfigurations.hikuo-macbook = withSystem "aarch64-darwin" (
    { inputs', ... }:
    inputs.nix-darwin.lib.darwinSystem {
      modules = [
        ./darwin/hikuo-macbook
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.hikuo = import ./home/hikuo-macbook;

          home-manager.extraSpecialArgs = {
            inherit inputs inputs';
            userInfo = {
              username = "hikuo";
              wallpaperPath = "/Users/hikuo/Pictures/wallpaper.jpg";
            };
          };
        }
      ]
      ++ lib.filesystem.listFilesRecursive ../modules/nix-darwin;
    }
  );
}
