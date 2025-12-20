{
  description = "hiro's dotfiles - shared library";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        debug = true; # option定義をnixdに公開する

        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];

        flake.lib = {
          listModules =
            path:
            let
              entries = builtins.readDir path;
              isNixFileOrDir =
                name: type: type == "directory" || (type == "regular" && nixpkgs.lib.strings.hasSuffix ".nix" name);
              filteredNames = nixpkgs.lib.attrsets.filterAttrs isNixFileOrDir entries;
            in
            map (name: path + "/${name}") (builtins.attrNames filteredNames);

          # Helper to convert directory entries to module attrset
          mkModulesFromDir =
            path:
            let
              entries = builtins.readDir path;
              isNixFileOrDir =
                name: type: type == "directory" || (type == "regular" && nixpkgs.lib.strings.hasSuffix ".nix" name);
              filteredEntries = nixpkgs.lib.attrsets.filterAttrs isNixFileOrDir entries;
              toModuleName = name: nixpkgs.lib.strings.removeSuffix ".nix" name;
            in
            builtins.listToAttrs (
              map (name: {
                name = toModuleName name;
                value = path + "/${name}";
              }) (builtins.attrNames filteredEntries)
            );
        };

        # home-manager modules
        flake.homeManagerModules =
          let
            modulesDir = ./modules/home;
            modules = inputs.self.lib.mkModulesFromDir modulesDir;
          in
          modules // { default = modulesDir; };

        # nix-darwin modules
        flake.darwinModules =
          let
            modulesDir = ./modules/nix-darwin;
            modules = inputs.self.lib.mkModulesFromDir modulesDir;
          in
          modules // { default = modulesDir; };

        # NixOS modules
        flake.nixosModules =
          let
            modulesDir = ./modules/nixos;
            modules = inputs.self.lib.mkModulesFromDir modulesDir;
          in
          modules // { default = modulesDir; };

        imports = [
          inputs.treefmt-nix.flakeModule
        ];

        perSystem =
          { ... }:
          {
            treefmt = {
              projectRootFile = "flake.nix";
              programs = {
                nixfmt-rfc-style.enable = true;
                yamlfmt.enable = true;
              };

              settings.formatter = {
              };
            };
          };
      }
    );
}
