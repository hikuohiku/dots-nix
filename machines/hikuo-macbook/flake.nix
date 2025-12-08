{
  description = "hikuo-macbook darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fish-ghq = {
      url = "github:decors/fish-ghq";
      flake = false;
    };
    fish-fzf-bd = {
      url = "github:yuys13/fish-fzf-bd";
      flake = false;
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };

      listModules =
        path:
        let
          entries = builtins.readDir path;
          isNixFileOrDir =
            name: type: type == "directory" || (type == "regular" && nixpkgs.lib.strings.hasSuffix ".nix" name);
          filteredNames = nixpkgs.lib.attrsets.filterAttrs isNixFileOrDir entries;
        in
        map (name: path + "/${name}") (builtins.attrNames filteredNames);
    in
    {
      darwinConfigurations.hikuo-macbook = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./host.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hikuo = {
              imports = [ ./home.nix ] ++ listModules ../../modules/nix-darwin/home;
            };

            home-manager.extraSpecialArgs = {
              inherit inputs;
              userInfo = {
                username = "hikuo";
                wallpaperPath = "/Users/hikuo/Pictures/wallpaper.jpg";
              };
            };
          }
        ] ++ listModules ../../modules/nix-darwin;
      };
    };
}
