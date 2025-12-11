{
  description = "hikuo-desktop NixOS configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    aylur = {
      url = "github:Aylur/dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };
    astal = {
      url = "github:Aylur/astal";
    };

    fish-ghq = {
      url = "github:decors/fish-ghq";
      flake = false;
    };
    fish-fzf-bd = {
      url = "github:yuys13/fish-fzf-bd";
      flake = false;
    };

    catppuccin.url = "github:catppuccin/nix";
    diniamo = {
      url = "github:diniamo/niqspkgs"; # bibata-hyprcursor
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mylib = {
      url = "github:hikuohiku/dots-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        ./configuration.nix
      ];
    };
}
