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

モジュール変更の検証〜コミット〜プッシュは `/nix-module-ci` skill を使う（生の
`darwin-rebuild` / `nixos-rebuild` を直接叩かない）。

```bash
# macOS: 設定を適用
darwin-rebuild switch --flake ./machines/hikuo-macbook

# NixOS: 設定を適用
sudo nixos-rebuild switch --flake ./machines/hikuo-desktop

# flake 入力を更新
nix flake update
```

`hikuo-desktop` では `nixos-rebuild` が NOPASSWD 化されており
(`machines/hikuo-desktop/modules/claude-rebuild.nix`)、`/nix-module-ci hikuo-desktop`
はビルド成功後に自動で `switch` する（switch は activation がワークディレクトリ外へ
書き込むため Bash サンドボックスを無効化して実行）。

### フォーマットについて（メモ）

`nix fmt` は flake が nix 式として評価できないと動かず、flake 自体が設定本体である
dots-nix では不向き。将来的にフォーマッターを直接実行する想定だが未整備のため、
現状フォーマット用コマンドは無い。新規・変更ファイルは近いモジュールの既存スタイルに倣う。

## Conventions

- モジュールは `modules/<app>/` に配置し、`default.nix` をエントリポイントとする
- `my.apps.<app>.enable = true;` でアプリケーションを有効化する設計
- darwin/home-manager/nixos で共有可能な設定は共通モジュールに抽出する
- ハードコードされたパスやユーザー名は避け、`config` から参照する
- アプリの設定ファイルは home-manager の `settings`（生成方式）ではなく、実ファイルを
  `modules/<app>/` に置き `xdg.configFile."<app>/...".source = ./<file>;` で symlink する
  （例: `modules/zellij/`）
- 設定を nix 式で生成するより、アプリ本来の形式の raw 設定ファイルで持つことを優先する。
  nix の生成層（型付きラッパや `settings`）はアプリ上流の更新に追従しきれず新機能対応が
  遅延しがちなため。型付きラッパしか入口が無い場合でも、raw ファイルを読み込ませる経路
  （`builtins.readFile` 等）があればそちらを使う

## Plan 資料

- plan mode で書く計画ファイルには、詳細な実装手順（正確性のため現状の粒度を維持）に
  加えて、冒頭にユーザーが素早く読める端的で構造的な要約（変更点の概要）を含める

## Git Workflow

- 個人管理リポジトリのため main ブランチへ直接コミットしてよい
- コミット後はコンフリクトがないことを確認した上で即座に `git push` する
