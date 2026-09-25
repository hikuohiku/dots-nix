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

# NixOS: 設定を適用（人は nh、Claude は NOPASSWD の nixos-rebuild）
nh os switch
sudo nixos-rebuild switch --flake ./machines/hikuo-desktop

# flake 入力を更新
nix flake update
```

`hikuo-desktop` では `nixos-rebuild` が NOPASSWD 化されており
(`machines/hikuo-desktop/modules/claude-rebuild.nix`)、適用時にパスワード入力は不要。
nh は `sudo env ...` で昇格し sudoers で絞り込めないため、Claude は nixos-rebuild を使う。

各マシンの flake は共有モジュールを `my = { url = "path:../.."; }` の相対パスで参照する。
rev を lock しないため、ローカル checkout が常にそのまま使われる。

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
- 並列セッションは worktree で隔離する（グローバル `parallel-worktree` skill 参照）。
  ビルド検証（`--override-input my .`）は並列安全だが、`switch` は同一マシンで並列に
  行わない（検証順を直列化するため）
