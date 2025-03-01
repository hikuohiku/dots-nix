{
  description = "hiro's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

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

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      catppuccin,
      ...
    }@inputs:
    let
      userInfo = import ./config/user.nix;
      pkgs = import nixpkgs {
        system = userInfo.system;
        config.allowUnfree = true;
      };
      # External packages
      aylurpkgs = inputs.aylur.packages.${userInfo.system};
      diniamopkgs = inputs.diniamo.packages.${userInfo.system};
      zen-browser = inputs.zen-browser.packages.${userInfo.system};
      # Treefmt configuration
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    rec {
      formatter.${userInfo.system} = treefmtEval.config.build.wrapper;
      checks.${userInfo.system}.formatting = treefmtEval.config.build.check self;

      # NixOS configurations
      nixosConfigurations = {
        ${userInfo.hostname} = nixpkgs.lib.nixosSystem {
          system = userInfo.system;
          specialArgs = {
            inherit inputs userInfo;
          };
          modules = [
            ./hosts/nixos/hikuo-desktop
            catppuccin.nixosModules.catppuccin
          ];
        };
      };

      # Home Manager configurations
      # TODO: nixos moduleにする
      homeConfigurations = {
        ${userInfo.username} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              inputs
              aylurpkgs
              diniamopkgs
              zen-browser
              userInfo
              ;
          };
          modules = [
            ./hosts/home/hikuo-desktop
            catppuccin.homeManagerModules.catppuccin
          ];
        };
      };

      darwinConfigurations = {
        ${userInfo.hostname} = nix-darwin.lib.darwinSystem {
          modules = [
            ./hosts/darwin/hikuo-macbook
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${userInfo.username} = import ./hosts/home/hikuo-macbook;

              home-manager.extraSpecialArgs = {
                inherit userInfo;
              };
            }
          ];
        };
      };
    };
}
