{
  withSystem,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.hikuo-desktop = withSystem "x86_64-linux" (
    { inputs', ... }:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.catppuccin.nixosModules.catppuccin
      ]
      ++ inputs.mylib.lib.listModules ./modules
      ++ inputs.mylib.lib.listModules ../../modules/nixos;

      specialArgs = {
        inherit inputs inputs';
        userInfo = {
          username = "hikuo";
        };
        systemInfo = {
          hostname = "hikuo-desktop";
        };
      };
    }
  );

  flake.homeConfigurations.hikuo = withSystem "x86_64-linux" (
    { pkgs, inputs', ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
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
      modules = [
        ./modules/home/base.nix
        inputs.catppuccin.homeManagerModules.catppuccin
      ];
    }
  );
}
