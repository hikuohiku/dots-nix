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
      ]
      ++ inputs.mylib.lib.listModules ./modules
      ++ inputs.mylib.lib.listModules ../../modules/nix-darwin;

      specialArgs = {
        inherit inputs inputs';
      };
    }
  );
}
