#!/usr/bin/env python3
"""Mozc UT 辞書を azooKey のユーザー辞書 (user.louds ほか) へ変換する。

使い方: hazkey-ut-dict.py <charID.chid> <出力先> <*.txt.bz2>...
"""
import array
import bz2
import struct
import sys
from pathlib import Path

CID = 1285  # 一般名詞
MID = 501  # 一般
SHIFT = 11  # loudstxt3 の 1 ファイルあたりのスロット数の指数


def value(cost):
    """Mozc のコストを azooKey の対数確率へ変換する。

    標準辞書の語より低くし、通常の文の変換結果を変えにくくする。-11 まで上げると文が崩れた。
    """
    return -14.0 - (cost - 8000) / 500.0


def load(paths, char_ids):
    """読みを片仮名にし、(読み, 語) ごとに最小コストを返す。charID に無い文字を含む読みは捨てる。"""
    to_kata = {c: c + 0x60 for c in range(ord("ぁ"), ord("ゖ") + 1)}
    best = {}
    for path in paths:
        with bz2.open(path, "rt", encoding="utf-8") as f:
            for line in f:
                yomi, _, _, cost, word = line.rstrip("\n").split("\t")
                ruby = yomi.translate(to_kata)
                if all(c in char_ids for c in ruby):
                    key = (ruby, word)
                    best[key] = min(int(cost), best.get(key, 1 << 30))
    return best


def build_trie(keys, char_ids):
    """文字 ID 順の読みから LOUDS のビット列、ノードの文字、読みごとのノード番号を作る。"""
    bits = bytearray([1, 0])
    chars = bytearray([0, 0])
    index_of = {}
    next_index = 2
    level = [(0, len(keys))]  # 同じ親を持つ読みの範囲を深さごとに持つ。
    depth = 0
    while level:
        next_level = []
        for lo, hi in level:
            i = lo
            while i < hi and len(keys[i]) == depth:
                i += 1
            children = 0
            while i < hi:
                ch = keys[i][depth]
                j = i
                while j < hi and keys[j][depth] == ch:
                    j += 1
                next_level.append((i, j))
                children += 1
                i = j
            bits.extend(b"\x01" * children + b"\x00")
        for lo, _ in next_level:
            chars.append(char_ids[keys[lo][depth]])
            if len(keys[lo]) == depth + 1:
                index_of[keys[lo]] = next_index
            next_index += 1
        level = next_level
        depth += 1
    return bits, chars, index_of


def write_louds(bits, chars, out):
    """ビット列を上位ビットから詰めた 64 ビット語にし、余りを 1 で埋めて書き出す。"""
    while len(bits) % 64:
        bits.append(1)
    words = array.array("Q")
    for i in range(0, len(bits), 64):
        v = 0
        for b in bits[i : i + 64]:
            v = (v << 1) | b
        words.append(v)
    (out / "user.louds").write_bytes(words.tobytes())
    (out / "user.loudschars2").write_bytes(bytes(chars))


def write_loudstxt3(by_ruby, index_of, out):
    """ノード番号の上位ビットをファイル、下位ビットをスロットとして語を書き出す。"""
    slots_per_file = 1 << SHIFT
    files = {}
    for ruby, rows in by_ruby.items():
        idx = index_of[ruby]
        payload = bytearray(struct.pack("<H", len(rows)))
        for _, cost in rows:
            payload += struct.pack("<HHHf", CID, CID, MID, value(cost))
        payload += "\t".join([ruby] + ["" if w == ruby else w for w, _ in rows]).encode()
        files.setdefault(idx >> SHIFT, {})[idx & (slots_per_file - 1)] = bytes(payload)
    empty = struct.pack("<H", 0)
    for number, slots in files.items():
        payloads = [slots.get(i, empty) for i in range(slots_per_file)]
        offset = 2 + 4 * slots_per_file
        head = bytearray(struct.pack("<H", slots_per_file))
        for p in payloads:
            head += struct.pack("<I", offset)
            offset += len(p)
        (out / f"user{number}.loudstxt3").write_bytes(bytes(head) + b"".join(payloads))


def main():
    chid, out, *paths = sys.argv[1:]
    out = Path(out)
    out.mkdir(parents=True, exist_ok=True)
    char_ids = {c: i for i, c in enumerate(Path(chid).read_text(encoding="utf-8"))}
    by_ruby = {}
    for (ruby, word), cost in load(paths, char_ids).items():
        by_ruby.setdefault(ruby, []).append((word, cost))
    keys = sorted(by_ruby, key=lambda r: [char_ids[c] for c in r])
    bits, chars, index_of = build_trie(keys, char_ids)
    write_louds(bits, chars, out)
    write_loudstxt3(by_ruby, index_of, out)
    print(f"{sum(map(len, by_ruby.values()))} words, {len(keys)} readings")


if __name__ == "__main__":
    main()
