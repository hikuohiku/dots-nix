# hikuohiku dotfiles

## Documentation

- [modules/](./modules/README.md) - モジュールの構成と読み込み方式

## Tips

### 変更差分の確認方法

[`nix-diff`](https://github.com/Gabriella439/nix-diff) を使うと 2 つの derivation の差分を確認できる。依存 derivation を再帰的に辿って、変化した環境変数・入力・ビルドコマンドを表示してくれる。

```fish
# 比較したい 2 つの drvPath を用意する
# (例: 変更前後、異なる機種、異なるブランチなど)
set a /nix/store/xxx...drv
set b (nix eval --raw ./machines/hikuo-macbook#darwinConfigurations.hikuo-macbook.config.system.build.toplevel.drvPath)

# 差分を確認
nix run nixpkgs#nix-diff -- $a $b
```

> [!NOTE]
> `nix eval .#...drvPath` で derivation (`.drv`) を `/nix/store/` に instantiate できる。

## Inspired by

- <https://github.com/Comamoca/dotfiles>
- ~~<https://github.com/mylinuxforwork/dotfiles>~~
