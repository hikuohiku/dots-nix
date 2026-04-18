# machines/ 配下の構造

各マシンディレクトリは 2 つの Nix モジュール層で構成する。

## scaffolding 層 (flake-parts モジュール)

- ファイル: `<machine>/darwin.nix` (nix-darwin) / 将来 `<machine>/nixos.nix` (NixOS)
- 責務: flake input から option を提供するモジュールを集めて `nix-darwin.lib.darwinSystem` (あるいは `nixosSystem`) に束ねる
- ここでは `mymodule.apps.*` のような machine-specific な option 値は設定しない

## configuration 層 (darwin / home-manager モジュール)

- ファイル: `<machine>/modules/configuration.nix` をエントリポイントとして、sibling module (`host.nix` / `apps.nix` / `home.nix` など) を `imports` で集約
- 責務: scaffolding 層が用意した option に値を与えてマシン固有設定を構成
- ここでは flake input そのものは import しない (scaffolding 層経由で option として見える)

## 層の分離意図

両者は Nix モジュール系の異なる層 (flake-parts モジュール vs darwin/HM モジュール) に属するので、ディレクトリ構造でも分ける: scaffolding は `<machine>/` 直下、configuration は `<machine>/modules/` 配下。
