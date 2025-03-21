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
        ./base.nix
        inputs.catppuccin.nixosModules.catppuccin
      ];
    }
  );
}
