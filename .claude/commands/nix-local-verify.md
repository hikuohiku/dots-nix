machines/ 以下の flake で `my` input をローカルパスに一時的に切り替え、モジュールの変更をビルド検証し、元に戻す。

## 手順

1. 対象マシンの `flake.nix` で `my` input の URL を `path:../../` に書き換える
2. 新しいモジュールファイルが未 stage なら `git add` する（Nix flake は git tracked ファイルのみ認識するため）
3. `nix flake update my --flake ./machines/<machine>` を実行して lock を更新する
4. `nix eval` や `darwin-rebuild build` / `nixos-rebuild build` でビルド検証する
5. 検証完了後、`flake.nix` の `my` input を元の GitHub URL に戻す
6. `flake.lock` の `my` エントリも元に戻す（`git checkout -- machines/<machine>/flake.lock` か再度 `nix flake update my`）

## 実行例

対象マシン: $ARGUMENTS (デフォルト: hikuo-macbook)

### 検証フロー

```
machine_dir="machines/${ARGUMENTS:-hikuo-macbook}"

# 1. my input をローカルパスに切り替え
# flake.nix 内の my.url を "path:../../" に変更する

# 2. 未 stage のモジュールファイルを git add
# git add modules/<new-module>/

# 3. flake lock を更新
# nix flake update my --flake ./$machine_dir

# 4. ビルド検証（darwin の場合）
# nix eval ./$machine_dir#darwinConfigurations.<host>.config.<option>
# darwin-rebuild build --flake ./$machine_dir

# 5. 検証完了後に元に戻す
# flake.nix の my.url を "github:hikuohiku/dots-nix" に戻す
# git checkout -- $machine_dir/flake.lock
```

上記の手順を順番に実行してください。検証対象のオプションやビルドコマンドは直前のコンテキストから判断してください。
