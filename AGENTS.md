# AGENTS.md

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
# macOS: 設定を適用（人は nh、Claude は NOPASSWD の darwin-rebuild）
nh darwin switch
sudo darwin-rebuild switch --flake ./machines/hikuo-macbook

# NixOS: 設定を適用（人は nh、Claude は NOPASSWD の nixos-rebuild）
nh os switch
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
- ソースビルドを避ける。flake に求めるのはバイナリの取得・配置と設定ファイルの配置で、
  nixpkgs や `programs` モジュールに固執しない。cache.nixos.org に無いもの（unfree、
  override 付き、`cudaSupport` 等）は次のいずれかに置き換える
  - 上流リリースのバイナリ: `modules/upstream/sources.json` に登録し、`upstream.<name>.src`
    で取得する。版は `modules/upstream/update.sh`（週次 CI でも実行）で最新に追従する
  - 自己更新するネイティブインストーラ: `modules/native-install.nix`（例: Claude Code）
- 上流バイナリを使うときは必ず更新に追従できる状態を保つ（アプリ自身の自動更新、
  または上記の更新スクリプト）。ハッシュを手書きで固定したままにしない

## Git Workflow

- 個人管理リポジトリのため main ブランチへ直接コミットしてよい
- コミット後はコンフリクトがないことを確認した上で即座に `git push` する
