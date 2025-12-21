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
      ]
      ++ builtins.attrValues (inputs.my.lib.mkModulesFromDir ./modules);

      specialArgs = {
        inherit inputs inputs';
      };
    }
  );
}
