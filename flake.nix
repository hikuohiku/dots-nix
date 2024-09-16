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
    };
    catppuccin.url = "github:catppuccin/nix";
    diniamo = {
      url = "github:diniamo/niqspkgs"; # bibata-hyprcursor
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
      aylurpkgs = inputs.aylur.packages.x86_64-linux;
      diniamopkgs = inputs.diniamo.packages.${userInfo.system};
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      formatter.x86_64-linux = treefmtEval.config.build.wrapper;

      nixosConfigurations.${userInfo.hostname} = nixpkgs.lib.nixosSystem {
        system = userInfo.system;
        specialArgs = {
          inherit inputs;
          inherit userInfo;
        };
        modules = [
          ./nixos/configuration.nix
          catppuccin.nixosModules.catppuccin
        ];
      };

      homeConfigurations = {
        ${userInfo.username} = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = userInfo.system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs;
            inherit aylurpkgs;
            inherit diniamopkgs;
            inherit userInfo;
          };
          modules = [
            ./home
            ./home/waybar
          ];
        };
      };
    };
}
