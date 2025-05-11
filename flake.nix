{
  description = "hiro's dotfiles";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    fish-ghq = {
      url = "github:decors/fish-ghq";
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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];
        imports = [
          inputs.home-manager.flakeModules.home-manager
          inputs.treefmt-nix.flakeModule
          ./hosts/nixos/hikuo-desktop
          ./hosts/home/hikuo-desktop
          ./hosts/hikuo-macbook.nix
        ];

        flake = {
          nixosConfigurations.proxmox = withSystem "x86_64-linux" (
            { pkgs, inputs', ... }:
            inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {
                inherit inputs inputs';
                userInfo = {
                  username = "hikuo";
                  git = {
                    username = "hikuohiku";
                    email = "hikuohiku@gmail.com";
                  };
                };
              };
              modules = [
                ./hosts/nixos/hikuo-homeserver
                inputs.home-manager.nixosModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.users.hikuo = {
                    imports = [
                      ./modules/home/core
                    ];
                    programs.home-manager.enable = true;
                    home.stateVersion = "25.05";

                    home.packages = with pkgs; [
                      firefox
                      git
                    ];
                  };

                  home-manager.extraSpecialArgs = {
                    inherit inputs inputs';
                    userInfo = {
                      username = "hikuo";
                      git = {
                        username = "hikuohiku";
                        email = "hikuohiku@gmail.com";
                      };
                    };
                  };
                }
              ];
            }
          );
          packages.x86_64-linux = {
            proxmox = withSystem "x86_64-linux" (
              { pkgs, inputs', ... }:
              inputs.nixos-generators.nixosGenerate {
                system = "x86_64-linux";
                format = "proxmox";
                modules = [
                  ./hosts/nixos/hikuo-homeserver
                  inputs.home-manager.nixosModules.home-manager
                  {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.users.hikuo = {
                      imports = [
                        ./modules/home/core
                      ];
                      programs.home-manager.enable = true;
                      home.stateVersion = "25.05";

                      home.packages = with pkgs; [
                        firefox
                        git
                      ];
                    };

                    home-manager.extraSpecialArgs = {
                      inherit inputs inputs';
                      userInfo = {
                        username = "hikuo";
                        git = {
                          username = "hikuohiku";
                          email = "hikuohiku@gmail.com";
                        };
                      };
                    };
                  }
                ];
              }
            );
          };
        };
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
