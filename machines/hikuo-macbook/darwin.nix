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
        inputs.home-manager.darwinModules.home-manager
        inputs.my.darwinModules.default
        ../../modules-2/darwin.nix
        ./modules/configuration.nix
      ];

      specialArgs = {
        inherit inputs inputs';
        mylib = inputs.my.lib;
      };
    }
  );
}
