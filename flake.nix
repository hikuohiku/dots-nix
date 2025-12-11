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
        };

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
