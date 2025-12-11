{
  withSystem,
  inputs,
  ...
}:
{
  flake.darwinConfigurations.hikuo-macbook = withSystem "aarch64-darwin" (
    { inputs', ... }:
    inputs.nix-darwin.lib.darwinSystem {
      modules = [
        ./host.nix
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.hikuo = {
            imports = [
              ./home.nix
            ] ++ inputs.mylib.lib.listModules ../../modules/nix-darwin/home;
          };

          home-manager.extraSpecialArgs = {
            inherit inputs inputs';
            userInfo = {
              username = "hikuo";
              wallpaperPath = "/Users/hikuo/Pictures/wallpaper.jpg";
            };
          };
        }
      ] ++ inputs.mylib.lib.listModules ../../modules/nix-darwin;
    }
  );
}
