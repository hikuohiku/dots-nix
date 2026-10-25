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
# macOS: 設定を適用（人は nh、Claude は NOPASSWD の darwin-rebuild）
nh darwin switch
sudo darwin-rebuild switch --flake ./machines/hikuo-macbook

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
- ソースビルドを避ける。flake に求めるのはバイナリの取得・配置と設定ファイルの配置で、
  nixpkgs や `programs` モジュールに固執しない。cache.nixos.org に無いもの（unfree、
  override 付き、`cudaSupport` 等）は次のいずれかに置き換える
  - 自己更新する公式インストーラ（優先）: `mymodule.nativeInstall.<name>` で宣言する
    （`modules/native-install/`、例: Claude Code, Codex）。アプリ自身が自動更新を持つならこれを使う
  - 上流リリースのバイナリ: `modules/upstream/sources.json` に登録し、`upstream.<name>.src`
    で取得する。版は `modules/upstream/update.sh`（週次 CI でも実行）で最新に追従する
- 上流バイナリを使うときは必ず更新に追従できる状態を保つ（アプリ自身の自動更新、
  または上記の更新スクリプト）。ハッシュを手書きで固定したままにしない
- macOS では PATH に入る CLI・アプリを brew で導入する（`modules/<app>/darwin.nix` の
  `homebrew.brews` / `casks`）。home.nix 側の nixpkgs は Linux 限定にする（例: `modules/git/`）。
  更新は `brew autoupdate` が毎日行う。ただし nix 固有のツール（nh, nil, nixd 等）、
  ログインシェルの fish、nix-darwin / home-manager のサービス（syncthing 等）は nix のままにする

## Plan 資料

- plan mode で書く計画ファイルには、詳細な実装手順（正確性のため現状の粒度を維持）に
  加えて、冒頭にユーザーが素早く読める端的で構造的な要約（変更点の概要）を含める

## Git Workflow

- 個人管理リポジトリのため main ブランチへ直接コミットしてよい
- コミット後はコンフリクトがないことを確認した上で即座に `git push` する
- 並列セッションは worktree で隔離する（グローバル `parallel-worktree` skill 参照）。
  ビルド検証（`--override-input my .`）は並列安全だが、`switch` は同一マシンで並列に
  行わない（検証順を直列化するため）
