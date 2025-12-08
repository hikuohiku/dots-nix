{
  description = "hikuo-macbook darwin configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

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
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" ];

      _module.args = {
        mylib = {
          listModules =
            path:
            let
              entries = builtins.readDir path;
              isNixFileOrDir =
                name: type: type == "directory" || (type == "regular" && nixpkgs.lib.strings.hasSuffix ".nix" name);
              filteredNames = nixpkgs.lib.attrsets.filterAttrs isNixFileOrDir entries;
            in
            map (name: path + "/${name}") (builtins.attrNames filteredNames);
        };
      };

      imports = [
        ./darwin.nix
      ];
    };
}
