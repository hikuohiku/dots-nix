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
        {
          mymodule.apps.alacritty.enable = true;
          mymodule.apps.zen.enable = true;
          mymodule.apps.neovim.enable = true;
          mymodule.apps.vscode.enable = true;
          mymodule.apps.fortivpn.enable = true;
          mymodule.apps.syncthing.enable = true;
          mymodule.apps.nix.enable = true;
          mymodule.apps.system.enable = true;
          mymodule.apps.touchid.enable = true;
          mymodule.apps.linux-builder.enable = true;
          mymodule.apps.karabiner.enable = true;
          mymodule.apps.ghostty.enable = true;
          mymodule.apps.fonts.enable = true;
          mymodule.apps.brew.enable = true;
          # mymodule.apps.yabai.enable = true;
          # mymodule.apps.skhd.enable = true;
        }
      ]
      ++ builtins.attrValues (inputs.my.lib.mkModulesFromDir ./modules);

      specialArgs = {
        inherit inputs inputs';
        mylib = inputs.my.lib;
      };
    }
  );
}
