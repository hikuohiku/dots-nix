{
  description = "hiro's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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

    catppuccin.url = "github:catppuccin/nix";
    diniamo = {
      url = "github:diniamo/niqspkgs"; # bibata-hyprcursor
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, ... }@inputs:
    let
      userInfo = import ./config/user.nix;
      pkgs = nixpkgs.legacyPackages.${userInfo.system};
      # External packages
      aylurpkgs = inputs.aylur.packages.${userInfo.system};
      diniamopkgs = inputs.diniamo.packages.${userInfo.system};
      zen-browser = inputs.zen-browser.packages.${userInfo.system};
      # Treefmt configuration
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    rec {
      formatter.${userInfo.system} = treefmtEval.config.build.wrapper;

      # NixOS configurations
      nixosConfigurations = {
        # デスクトップマシンの設定
        ${userInfo.hostname} = nixpkgs.lib.nixosSystem {
          system = userInfo.system;
          specialArgs = {
            inherit inputs userInfo;
          };
          modules = [
            # Base system configuration
            ./modules/nixos/base
            # Host-specific configuration
            ./hosts/desktop
            catppuccin.nixosModules.catppuccin
          ];
        };
      };

      # Home Manager configurations
      homeConfigurations = {
        ${userInfo.username} = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = userInfo.system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs aylurpkgs diniamopkgs zen-browser userInfo;
          };
          modules = [
            # CLI tools and basic configuration
            ./modules/home/cli
            # Desktop environment and GUI applications
            ./modules/home/desktop
            # Aylur's configuration (for Hyprland setup)
            ./home/unixporn/aylur
            # Theme configuration
            catppuccin.homeManagerModules.catppuccin
          ];
        };
      };
    };
}
