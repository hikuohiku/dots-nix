---
name: disk-free
description: "macOS のストレージ逼迫を解消する。まず diskutil / df で「実際にどのボリューム・領域が容量を食っているか」を正しく計測し（APFS は複数ボリュームが1コンテナを共有し、symlink/hardlink/snapshot で du の数字がブレるため）、その後に項目別の解放手順を適用する。『Macのストレージを掃除したい』『容量が足りない』『どこが容量を食っているか分からない』ときに使う。解放手順は items/ 配下に項目ごとの独立ファイルとして並んでおり、新しい手段は items/ にファイルを足すだけで拡張できる。"
---

# disk-free — macOS ストレージ解放

macOS のディスク逼迫を「**正しく計測 → 項目別に解放**」の2段で片付ける。

計測が分かりにくいのは、APFS では複数ボリューム（Data / Nix Store / VM / Preboot…）が
**1つのコンテナを共有**しており、さらに symlink・hardlink・APFS clone・snapshot・
purgeable のせいで `du` の数字が実際の物理消費とズレるため。まず物理の真実を掴む。

## 手順

### STEP 1. 現状を計測する（diskutil / df）

物理消費の**唯一の真実はボリューム単位の "Capacity Consumed"**。フォルダ `du` の合計ではなくこちらを基準にする。

```bash
# コンテナ全体とボリュームごとの物理消費（dedup/clone/hardlink考慮済みの物理値）
diskutil apfs list | grep -iE "Capacity|Name|Snapshot"

# 各ボリュームの空き/使用（同一コンテナなら Avail は共有）
df -h / /System/Volumes/Data

# 特定ボリュームの詳細
diskutil info /System/Volumes/Data | grep -iE "Used|Free|Purgeable|Capacity"
```

ここで「ホームの外」「別ボリューム（/nix など）」に巨大な消費が無いかを最初に見る。
Finder でホームを見るだけでは別ボリュームの消費に気づけない。

### STEP 2. フォルダ単位で内訳を出す（du の注意点つき）

```bash
du -shx ~/* ~/.* 2>/dev/null | sort -rh | head -20      # ホーム直下
sudo du -shx /Applications /Library /opt /usr/local /private/var 2>/dev/null | sort -rh
sudo du -shx /System/Volumes/Data 2>/dev/null            # Data live ツリーの真の総量
```

**du の数字がズレる理由（計測時に必ず意識する）:**
- **Top-N の切り捨て**: `head -15` 等で上位だけ見ると、中小ディレクトリの裾野が合計から漏れる。
  「内訳の合計 ≠ ボリューム総量」になったらまずこれを疑う。
- **hardlink**: 同一 `du` ツリー内は1回だけカウント（正）。ただし**別々に `du` を回すと二重計上**する。
- **APFS clone**: 実体は共有でもフルサイズで計上され**過大**に出る。
- **snapshot / purgeable / メタデータ**: `du` には**原理的に見えない**が物理ブロックは食う。
  下のコマンドで別途確認する。

```bash
tmutil listlocalsnapshots /                              # ローカルスナップショット
diskutil info / | grep -i purgeable
```

GUI で見るなら「アクティビティモニタ」ではなく GrandPerspective / DaisyDisk / `ncdu -x` /
`dust`（いずれも hardlink 認識）。

### STEP 3. 項目別に解放する

`items/` 配下に**項目ごとの独立した解放手順**がある。STEP 1–2 で見つかった大物に対応する
ファイルを開いて適用する。各ファイルは自己完結しており、互いに依存しない。

| 項目ファイル | 対象 | 典型的な効果 |
|---|---|---|
| [items/nix-store.md](items/nix-store.md) | `/nix`（Nix / nix-darwin の古い世代） | 大（数十〜100GB級） |

> 新しい解放手段を足すときは `items/<topic>.md` を1ファイル追加し、この表に1行加えるだけ。
> 既存項目には触れない（並列に書ける）。今後の候補: Xcode `~/Library/Developer`、
> `brew cleanup`、`/usr/local/texlive`、APFS スナップショット、各種 Caches など。

### STEP 4. 効果を実測する

解放コマンドの自己申告（"X GiB freed" 等）を鵜呑みにせず、STEP 1 と同じ
`diskutil info` / `df -h` で Before/After を比較して報告する。

## 原則

- **計測してから消す。** 何が容量を食っているか確定する前に削除手順を走らせない。
- **物理の真実はボリューム単位（diskutil Capacity Consumed / df Avail）。** du の合計は補助。
- **消す前に正体を確認する。** 実行中アプリの一時領域（`/private/var/folders` 等）や
  使用中のスワップ（VM ボリューム）は手動 `rm` しない。
- **root 権限が要る操作はユーザーに実行してもらう**（`! sudo ...` を提案）。勝手に sudo を試さない。
