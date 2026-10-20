#!/usr/bin/env bash
# sources.json の各エントリを GitHub の最新リリースに更新し、アセットのハッシュを取り直す。
# 使い方: modules/upstream/update.sh [name...]   (省略時は全件)
set -euo pipefail
cd "$(dirname "$0")"

names=("$@")
[ ${#names[@]} -eq 0 ] && mapfile -t names < <(jq -r 'keys[]' sources.json)

for name in "${names[@]}"; do
  repo=$(jq -r --arg n "$name" '.[$n].repo' sources.json)
  prefix=$(jq -r --arg n "$name" '.[$n].tagPrefix' sources.json)
  # 同一リポジトリに別製品のタグが混在するので prefix で絞り、prerelease は除く。
  tag=$(curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$repo/releases?per_page=50" |
    jq -r --arg p "$prefix" '[.[] | select(.prerelease | not) | select(.tag_name | startswith($p))][0].tag_name')
  version=${tag#"$prefix"}

  json=$(jq --arg n "$name" --arg v "$version" '.[$n].version = $v' sources.json)
  for system in $(jq -r --arg n "$name" '.[$n].assets | keys[]' sources.json); do
    asset=$(jq -r --arg n "$name" --arg s "$system" '.[$n].assets[$s].name' sources.json)
    url="https://github.com/$repo/releases/download/$tag/${asset//\{version\}/$version}"
    hash=$(nix store prefetch-file --json "$url" | jq -r .hash)
    json=$(jq --arg n "$name" --arg s "$system" --arg h "$hash" '.[$n].assets[$s].hash = $h' <<<"$json")
  done
  printf '%s\n' "$json" >sources.json
  echo "$name: $version"
done
