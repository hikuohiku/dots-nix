{
  description = "hikuo-desktop NixOS configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
    # GlobalShortcuts portal の対応を含む未リリースの main をビルドする。
    # portal 対応版が nixpkgs に取り込まれたら、この入力と overlay を削除する。
    niri-src = {
      url = "github:niri-wm/niri";
      flake = false;
    };

    # OMP は公式リリースの事前ビルドを持つ flake を使い、Bun 依存のローカルビルドを避ける。
    omp.url = "github:bjin/oh-my-pi.nix";

    vicinae.url = "github:vicinaehq/vicinae";

    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dots-nix-private = {
      url = "git+https://github.com/hikuohiku/dots-nix-private";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DMS のバーに AI の利用枠を出すプラグイン。
    dms-ai-quotas = {
      url = "github:agneswd/dms-ai-quotas";
      flake = false;
    };
    # Hazkey のユーザー辞書の元データ。
    mozcdic-ut-jawiki = {
      url = "github:utuhiro78/mozcdic-ut-jawiki";
      flake = false;
    };
    mozcdic-ut-neologd = {
      url = "github:utuhiro78/mozcdic-ut-neologd";
      flake = false;
    };
    mozcdic-ut-skk-jisyo = {
      url = "github:utuhiro78/mozcdic-ut-skk-jisyo";
      flake = false;
    };
    mozcdic-ut-sudachidict = {
      url = "github:utuhiro78/mozcdic-ut-sudachidict";
      flake = false;
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
