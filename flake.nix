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
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
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
      home-manager,
      catppuccin,
      ...
    }@inputs:
    let
      userInfo = {
        username = "hikuo";
        hostname = "hikuo-desktop";
        system = "x86_64-linux";
        wallpaperPath = "/home/hikuo/Pictures/wallpaper.jpg";
        git = {
          username = "hikuohiku";
          email = "hikuohiku@gmail.com";
        };
      };
      pkgs = nixpkgs.legacyPackages.${userInfo.system};
      aylurpkgs = inputs.aylur.packages.${userInfo.system};
      diniamopkgs = inputs.diniamo.packages.${userInfo.system};
      zen-browser = inputs.zen-browser.packages.${userInfo.system};
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    rec {
      formatter.${userInfo.system} = treefmtEval.config.build.wrapper;

      nixosConfigurations = {
        hikuo-desktop = nixpkgs.lib.nixosSystem {
          system = userInfo.system;
          specialArgs = {
            inherit inputs;
            inherit userInfo;
          };
          modules = [
            ./nixos/configuration.nix
            ./nixos/hikuo-deskotp.nix
            ./nixos/hardware-configuration.desktop.nix
            catppuccin.nixosModules.catppuccin
          ];
        };
        hikuo-homeserver = nixpkgs.lib.nixosSystem {
          system = userInfo.system;
          specialArgs = {
            inherit inputs;
            inherit userInfo;
          };
          modules = [
            ./nixos/configuration.nix
            ./nixos/hikuo-homeserver.nix
            ./nixos/hardware-configuration.homeserver.nix
            catppuccin.nixosModules.catppuccin
          ];
        };
      };
      nixosConfigurations.nixos = nixosConfigurations.${userInfo.hostname};

      homeConfigurations = {
        ${userInfo.username} =
          if userInfo.hostname == "hikuo-desktop" then
            home-manager.lib.homeManagerConfiguration {
              pkgs = import nixpkgs {
                system = userInfo.system;
                config.allowUnfree = true;
              };
              extraSpecialArgs = {
                inherit inputs;
                inherit aylurpkgs;
                inherit diniamopkgs;
                inherit zen-browser;
                inherit userInfo;
              };
              modules = [
                ./home
                ./home/unixporn/aylur
                catppuccin.homeManagerModules.catppuccin
              ];
            }
          else if userInfo.hostname == "hikuo-homeserver" then
            home-manager.lib.homeManagerConfiguration {
              pkgs = import nixpkgs {
                system = userInfo.system;
                config.allowUnfree = true;
              };
              extraSpecialArgs = {
                inherit inputs;
                inherit aylurpkgs;
                inherit diniamopkgs;
                inherit zen-browser;
                inherit userInfo;
              };
              modules = [
                ./home/homeserver.nix
                catppuccin.homeManagerModules.catppuccin
              ];
            }
          else
            { };
      };
    };
}
