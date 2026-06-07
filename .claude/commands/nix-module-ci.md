モジュール変更のローカル検証からコミット・プッシュまでを一貫して行う。

対象マシン: $ARGUMENTS (デフォルト: hikuo-macbook)

## Phase 1: ローカルビルド検証

1. 新しいモジュールファイルが Nix flake から見えない場合は `git add -N <path>` で intent-to-add する（最終コミットの stage とは分ける）
2. `nix eval` や `darwin-rebuild build` / `nix build`（NixOS）に `--override-input my .` を付けて、ローカル checkout の共有モジュールを評価する
   - NixOS は ng 版 `nixos-rebuild` が `--no-out-link` 非対応のため、`nix build ...#nixosConfigurations.<machine>.config.system.build.toplevel --override-input my . --no-link --print-out-paths` を使う
3. 対象マシンごとの出力を使う
   - macOS: `./machines/hikuo-macbook#darwinConfigurations.hikuo-macbook`
   - NixOS: `./machines/hikuo-desktop#nixosConfigurations.hikuo-desktop`
4. 検証用に対象マシンの `flake.nix` を書き換えない
5. 検証用に対象マシンの `flake.lock` を更新しない

ビルドが失敗した場合はここで止めて原因を報告する。

## Phase 1.5: プッシュ前の動作確認ゲート

Phase 1 のビルドが通っても、コミット・プッシュの前に AskUserQuestion で実機での
動作確認結果を尋ねる。ビルド成功は「評価・ビルドが通る」保証にすぎず、意図通りに
動くかは実機適用 (`switch`) でしか分からないため。

- 必要なら先にローカル checkout を適用して確認できる
  - macOS: `darwin-rebuild switch --flake ./machines/<machine> --override-input my .`
  - NixOS: `sudo nixos-rebuild switch --flake ./machines/<machine> --override-input my .`
- AskUserQuestion の選択肢の例:
  - 動作確認 OK → push する
  - 確認できない / 不要 → push する
  - まだ push しない（保留）
- 「まだ push しない」が選ばれたら Phase 2/3 を実行せずに止まる

## Phase 2: モジュール変更のコミット・プッシュ

dots-nix flake に含まれるモジュール実装部分（`modules/`, `flake.nix` など）の変更をコミットしてプッシュする。

- 対象: `modules/` 以下の変更、ルートの `flake.nix` の変更など、共有モジュールに関わるファイル
- `machines/` 以下の変更はこのコミットに含めない
- コミット後に `git push` する

## Phase 3: マシン別変更のコミット・プッシュ

マシン固有の flake で `my` input の lock を更新し、マシン別の変更とまとめてコミット・プッシュする。

1. `nix flake update my --flake ./machines/<machine>` で Phase 2 のプッシュを反映した lock に更新する
2. マシン固有の変更（`enable` 追加、`machines/` 以下の設定変更など）があればまとめる
3. `machines/<machine>/flake.lock` の変更とマシン固有の変更をコミットしてプッシュする

## 実行例

```
machine_dir="machines/${ARGUMENTS:-hikuo-macbook}"

# --- Phase 1: ローカルビルド検証 ---
# 必要な場合だけ、新規ファイルを flake に認識させる
# git add -N modules/<new-module>/...
#
# macOS:
# nix eval ./$machine_dir#darwinConfigurations.hikuo-macbook.config.<option> --override-input my .
# darwin-rebuild build --flake ./$machine_dir --override-input my .
#
# NixOS:
# nix eval ./$machine_dir#nixosConfigurations.hikuo-desktop.config.<option> --override-input my .
# nix build ./$machine_dir#nixosConfigurations.hikuo-desktop.config.system.build.toplevel --override-input my . --no-link --print-out-paths

# --- Phase 2: モジュール変更のコミット・プッシュ ---
# git add modules/... flake.nix (modules/ 以下・ルート flake の変更のみ)
# git commit
# git push

# --- Phase 3: マシン別変更のコミット・プッシュ ---
# nix flake update my --flake ./$machine_dir
# git add $machine_dir/
# git commit
# git push
```

上記の手順を順番に実行してください。検証対象のオプションやビルドコマンドは直前のコンテキストから判断してください。
