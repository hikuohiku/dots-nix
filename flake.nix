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
          # Helper to create a module that imports default.nix + OS-specific files
          mkModuleWithPlatform =
            path:
            { pkgs, ... }:
            let
              system = pkgs.system;
              isLinux = builtins.match ".*-linux" system != null;
              isDarwin = builtins.match ".*-darwin" system != null;
            in
            {
              imports = [
                (path + "/default.nix")
              ]
              ++ nixpkgs.lib.optionals (isLinux && builtins.pathExists (path + "/linux.nix")) [
                (path + "/linux.nix")
              ]
              ++ nixpkgs.lib.optionals (isDarwin && builtins.pathExists (path + "/darwin.nix")) [
                (path + "/darwin.nix")
              ];
            };

          # Helper to convert directory entries to module attrset
          mkModulesFromDir =
            path:
            let
              inherit (inputs.self.lib) mkModuleWithPlatform;
              entries = builtins.readDir path;
              isNixFileOrDir =
                name: type: type == "directory" || (type == "regular" && nixpkgs.lib.strings.hasSuffix ".nix" name);
              filteredEntries = nixpkgs.lib.attrsets.filterAttrs isNixFileOrDir entries;
              toModuleName = name: nixpkgs.lib.strings.removeSuffix ".nix" name;
              mkModule =
                name: entryType:
                let
                  modulePath = path + "/${name}";
                in
                if entryType == "directory" then mkModuleWithPlatform modulePath else modulePath;
            in
            builtins.listToAttrs (
              map (name: {
                name = toModuleName name;
                value = mkModule name filteredEntries.${name};
              }) (builtins.attrNames filteredEntries)
            );
        };

        # home-manager modules
        flake.homeManagerModules =
          let
            modules = inputs.self.lib.mkModulesFromDir ./modules/home;
          in
          modules // { default.imports = builtins.attrValues modules; };

        # nix-darwin modules
        flake.darwinModules =
          let
            modules = inputs.self.lib.mkModulesFromDir ./modules/nix-darwin;
          in
          modules // { default.imports = builtins.attrValues modules; };

        # NixOS modules
        flake.nixosModules =
          let
            modules = inputs.self.lib.mkModulesFromDir ./modules/nixos;
          in
          modules // { default.imports = builtins.attrValues modules; };

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
