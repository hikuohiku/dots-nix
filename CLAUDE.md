# CLAUDE.md

Nix flakes ベースの dotfiles リポジトリ。macOS (nix-darwin) と NixOS の設定を管理する。

## Project Structure

```
flake.nix              # 共有モジュールを export する flake
machines/
  hikuo-macbook/       # macOS (nix-darwin + home-manager)
  hikuo-desktop/       # NixOS + home-manager
modules/
  darwin.nix           # nix-darwin 用エントリポイント
  home.nix             # home-manager 用エントリポイント
  nixos.nix            # NixOS 用エントリポイント
  <app>/               # アプリケーション別モジュール
```

## Commands

```bash
# macOS: 設定を適用
darwin-rebuild switch --flake ./machines/hikuo-macbook

# NixOS: 設定を適用
sudo nixos-rebuild switch --flake ./machines/hikuo-desktop

# flake 入力を更新
nix flake update

# フォーマット
nix fmt
```

## Conventions

- モジュールは `modules/<app>/` に配置し、`default.nix` をエントリポイントとする
- `my.apps.<app>.enable = true;` でアプリケーションを有効化する設計
- darwin/home-manager/nixos で共有可能な設定は共通モジュールに抽出する
- ハードコードされたパスやユーザー名は避け、`config` から参照する

## Git Workflow

- 個人管理リポジトリのため main ブランチへ直接コミットしてよい
- コミット後はコンフリクトがないことを確認した上で即座に `git push` する
