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
        inputs.my.nixosModules.default
        inputs.vicinae.nixosModules.default
        inputs.niri-flake.nixosModules.niri
        ./modules/configuration.nix
      ];

      specialArgs = {
        inherit inputs inputs';
        systemInfo = {
          hostname = "hikuo-desktop";
        };
      };
    }
  );
}
