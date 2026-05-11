モジュール変更のローカル検証からコミット・プッシュまでを一貫して行う。

対象マシン: $ARGUMENTS (デフォルト: hikuo-macbook)

## Phase 1: ローカルビルド検証

1. 対象マシンの `flake.nix` で `my` input の URL を `path:../../` に書き換える
2. 新しいモジュールファイルが未 stage なら `git add` する（Nix flake は git tracked ファイルのみ認識するため）
3. `nix flake update my --flake ./machines/<machine>` を実行して lock を更新する
4. `nix eval` や `darwin-rebuild build --no-out-link` / `nixos-rebuild build --no-out-link` でビルド検証する
5. 検証完了後、`flake.nix` の `my` input を元の GitHub URL に戻す
6. `flake.lock` の `my` エントリも元に戻す（`git checkout -- machines/<machine>/flake.lock`）

ビルドが失敗した場合はここで止めて原因を報告する。

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
# flake.nix 内の my.url を "path:../../" に変更
# git add modules/<new-module>/
# nix flake update my --flake ./$machine_dir
# darwin-rebuild build --no-out-link --flake ./$machine_dir  (or nixos-rebuild build --no-out-link)
# flake.nix の my.url を "github:hikuohiku/dots-nix" に戻す
# git checkout -- $machine_dir/flake.lock

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
