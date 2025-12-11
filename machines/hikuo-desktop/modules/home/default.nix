{ withSystem, inputs, ... }:
{
  flake.homeConfigurations.hikuo = withSystem "x86_64-linux" (
    ctx@{ pkgs, inputs', ... }:
    # TODO: nixos moduleにする
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
        ./base.nix
        inputs.catppuccin.homeManagerModules.catppuccin
      ];
    }
  );
}
