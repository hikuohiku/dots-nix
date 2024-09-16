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
    niqspkgs = {
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
      nixos-hardware,
      home-manager,
      hyprland,
      treefmt-nix,
      aylur,
      catppuccin,
      niqspkgs,
    }@inputs:
    let
      personalizeInput = {
        username = "hikuo";
        hostname = "hikuo-desktop";
        wallpaperPath = "/home/hikuo/Pictures/wallpaper.jpg";
        git = {
          username = "hikuohiku";
          email = "hikuohiku@gmail.com";
        };
      };
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      pkgsFromNiqs = niqspkgs.packages.x86_64-linux;
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      formatter.x86_64-linux = treefmtEval.config.build.wrapper;

      nixosConfigurations.${personalizeInput.hostname} = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          inputs.catppuccin.nixosModules.catppuccin
        ];
        specialArgs = {
          inherit inputs;
          inherit personalizeInput;
        };
      };

      homeConfigurations = {
        Home = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs;
            inherit pkgsFromNiqs;
            inherit personalizeInput;
          };
          modules = [
            ./home
            ./home/waybar
          ];
        };
      };
    };
}
