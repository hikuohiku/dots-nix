{
  withSystem,
  inputs,
  ...
}:
{
  flake.homeConfigurations.hikuo-homeserver = withSystem "x86_64-linux" (
    { pkgs, inputs', ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs inputs';
        mylib = inputs.my.lib;
        userInfo = {
          username = "hikuo";
          git = {
            username = "hikuohiku";
            email = "hikuohiku@gmail.com";
          };
        };
      };
      modules = [
        ./modules/home
        inputs.catppuccin.homeManagerModules.catppuccin
      ];
    }
  );
}
