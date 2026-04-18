{
  description = "hiro's dotfiles - shared modules";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      flake.darwinModules.default = ./modules/darwin.nix;
      flake.homeManagerModules.default = ./modules/home.nix;
      flake.nixosModules.default = ./modules/nixos.nix;
    };
}
