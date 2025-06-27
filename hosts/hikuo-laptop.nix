{ withSystem, inputs, ... }:
{
  flake.nixosConfigurations.hikuo-laptop = withSystem "x86_64-linux" (
    ctx@{ inputs', ... }:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs inputs';
        userInfo = {
          username = "hikuo";
        };
        systemInfo = {
          hostname = "hikuo-laptop";
        };
      };
      modules = [
        ./nixos/hikuo-laptop/configuration.nix
        ./nixos/hikuo-laptop/distributed-builds.nix
        inputs.nixos-hardware.nixosModules.microsoft-surface-laptop-amd
      ];
    }
  );
}
