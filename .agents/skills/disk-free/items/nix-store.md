# 項目: Nix store（/nix）の解放

`/nix/store` は **Data とは別の APFS ボリューム**なので、ホームを `du` しても気づけない。
nix-darwin / home-manager 環境では**古い世代（generation）がたまり続け**、各世代が
ストアパスを GC ルートとしてピン留めするため、放置すると数十〜100GB 級まで膨らむ。
（実例: 121.7GB → 14.9GB まで解放できたケースあり）

## 計測

```bash
diskutil info /nix | grep -i "Volume Used"          # 物理消費（真実）
du -sh /nix/store                                    # 参考（hardlinkで実体より小さく出ることも）
nix-collect-garbage --dry-run 2>&1 | tail -1         # 「N store paths would be deleted」
```

**世代数の数え方に注意**（`-d` 必須）:

```bash
ls -1d /nix/var/nix/profiles/system-*-link | wc -l   # 正しい: system世代の数
# ls -1（-dなし）はリンク先ディレクトリの中身まで列挙して数字が激増する。誤計測の罠。
```

## なぜ複数回・複数プロファイルを掃除する必要があるか

**プロファイル = 独立したパッケージ集合/構成**で、それぞれが**自分専用の世代履歴**を持つ
（Git のブランチ＝プロファイル、コミット＝世代、のイメージ）。
GC は「**どのプロファイルのどの世代からも参照されないパス**」しか消さないので、
**全プロファイルの古い世代を消さないと**容量は戻りきらない。

nix-darwin Mac の主なプロファイル:

| プロファイル | 場所 | 所有 | 掃除するコマンド |
|---|---|---|---|
| **system**（nix-darwin） | `/nix/var/nix/profiles/system` | **root** | `sudo` が必要 |
| **user / home-manager** | `~/.nix-profile` → `~/.local/state/nix/profiles/` | ユーザー | sudo 不要 |
| default / per-user/root | `/nix/var/nix/profiles/...` | root | sudo（大抵空） |

> 落とし穴: 非 sudo の `nix-collect-garbage --delete-old` は**ユーザープロファイルの世代だけ**
> を消す。**system の世代（142個などにたまりがち）は手つかず**のまま残り、大量のパスを
> ピン留めし続ける。だから sudo 版も必ず実行する。

## 解放手順

root 権限が要るので、ユーザーに `! sudo ...` で実行してもらう（自分で sudo を試さない）。

```bash
# 1. ユーザープロファイルの古い世代を削除 + GC（sudo不要）
nix-collect-garbage --delete-old

# 2. system 含む root 所有プロファイルの古い世代を削除 + GC（ここが本命）
#    sudo版の nix-collect-garbage は /nix/var/nix/profiles 配下（system含む）の
#    古い世代を消してから GC するので、これ一発で system 世代も片付く。
sudo nix-collect-garbage -d
#    ↑効かない/減らない場合のみ、明示的に system を狙い撃ち:
#    sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old
#    sudo nix-collect-garbage -d

# 3. （任意）ストア重複を hardlink で共有して追加削減
nix store optimise
```

ロールバック履歴を少し残したいなら 1 / 2 の `old`/`-d` の代わりに
`--delete-older-than 30d` や `--delete-generations +5`（最新5世代を保持）を使う。
**現用の起動中世代は常に残る**ので、古い世代を消してもシステムの動作には影響しない
（消えるのはロールバック先の履歴だけ）。

## 検証

```bash
ls -1d /nix/var/nix/profiles/system-*-link | wc -l   # 1（または保持数）に減ったか
diskutil info /nix | grep -i "Volume Used"           # Before/After を比較
df -h /System/Volumes/Data | tail -1                  # コンテナの Avail が増えたか
```

## 再発防止（nix-darwin 設定）

```nix
nix.gc = {
  automatic = true;
  interval = { Weekday = 0; Hour = 3; };   # 毎週日曜3時
  options = "--delete-older-than 30d";
};
nix.optimise.automatic = true;             # 定期 optimise
# 即時に重複排除したいなら: nix.settings.auto-optimise-store = true;
```

## メモ

- `optimise` の効果は store が大きい/重複が多いほど大きい。先に GC で縮めた後だと母数が
  減って効果は控えめ（例: 15GB の段階で実行して 1.5GiB）。大きく効かせたいなら早めに。
- `nix store optimise` は daemon 経由で動くため sudo 不要なことが多い。
