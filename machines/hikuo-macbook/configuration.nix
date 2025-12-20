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
        inputs.mylib.darwinModules.default
      ]
      ++ builtins.attrValues (inputs.mylib.lib.mkModulesFromDir ./modules);

      specialArgs = {
        inherit inputs inputs';
      };
    }
  );
}
