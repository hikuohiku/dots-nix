{
  description = "hikuo-desktop NixOS configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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

    catppuccin.url = "github:catppuccin/nix";
    diniamo = {
      url = "github:diniamo/niqspkgs"; # bibata-hyprcursor
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my = {
      url = "path:../..";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake.url = "github:sodiboo/niri-flake";

    # omp (oh-my-pi)。nixpkgs は follows させない（上流が bun2nix / rust-overlay を
    # 固定しており、ずらすと nix-community cachix に当たらず全ビルドになるため）。
    omp.url = "github:can1357/oh-my-pi";

    vicinae.url = "github:vicinaehq/vicinae";

    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
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
        ./nixos.nix
      ];
    };
}
