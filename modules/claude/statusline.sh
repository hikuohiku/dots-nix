#!/usr/bin/env bash
# Claude Code statusline.
# stdin から渡される JSON (model / rate_limits / workspace / transcript_path 等) を
# jq で読み、1 行に整形して出力する。特にセッション(5h)/週次リミットの使用率を表示する。
# 依存: jq, git (cli-tools 経由で PATH 上)。jq が無ければ何も出力せず終了。

set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)

# --- 値抽出 (欠落は空文字) ---
# 1 値 1 行で出力し mapfile で受ける。tab IFS だと連続区切りが畳まれ空フィールドが
# 位置ずれするため、改行区切り + mapfile(空行も保持)を使う。
mapfile -t F < <(
  printf '%s' "$input" | jq -r '
    (.model.display_name // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.workspace.current_dir // .cwd // ""),
    (.transcript_path // "")' 2>/dev/null
)
model=${F[0]-}
five_pct=${F[1]-}
five_reset=${F[2]-}
seven_pct=${F[3]-}
cwd=${F[4]-}
transcript=${F[5]-}

# ANSI カラー
C_RESET=$'\033[0m'
C_DIM=$'\033[2m'
C_GREEN=$'\033[32m'
C_YELLOW=$'\033[33m'
C_RED=$'\033[31m'
C_CYAN=$'\033[36m'
C_MAGENTA=$'\033[35m'

# 使用率(%)に応じた色: <50 緑, <80 黄, それ以上 赤
pct_color() {
  local p=${1%.*}
  [ -z "$p" ] && { printf '%s' "$C_DIM"; return; }
  if [ "$p" -lt 50 ]; then printf '%s' "$C_GREEN"
  elif [ "$p" -lt 80 ]; then printf '%s' "$C_YELLOW"
  else printf '%s' "$C_RED"; fi
}

# unix 秒 -> リセット時刻 "HH:MM" (ローカルタイム)
fmt_reset() {
  local target=$1
  [ -z "$target" ] && return
  date -d "@$target" +%H:%M 2>/dev/null
}

segments=()

# model
[ -n "$model" ] && segments+=("${C_CYAN}${model}${C_RESET}")

# 5h リミット
if [ -n "$five_pct" ]; then
  p=$(printf '%.0f' "$five_pct" 2>/dev/null || printf '%s' "$five_pct")
  seg="$(pct_color "$p")5h ${p}%${C_RESET}"
  r=$(fmt_reset "$five_reset")
  [ -n "$r" ] && seg="${seg} ${C_DIM}↻${r}${C_RESET}"
  segments+=("$seg")
fi

# 7d リミット
if [ -n "$seven_pct" ]; then
  p=$(printf '%.0f' "$seven_pct" 2>/dev/null || printf '%s' "$seven_pct")
  segments+=("$(pct_color "$p")7d ${p}%${C_RESET}")
fi

# context % (best-effort: transcript 末尾の最後の usage から概算, 上限 200k)
if [ -n "$transcript" ] && [ -r "$transcript" ]; then
  ctx=$(tac "$transcript" 2>/dev/null \
    | jq -c 'select(.message.usage) | .message.usage' 2>/dev/null \
    | head -1 \
    | jq -r '((.input_tokens // 0) + (.cache_read_input_tokens // 0)
             + (.cache_creation_input_tokens // 0) + (.output_tokens // 0))' 2>/dev/null)
  if [ -n "$ctx" ] && [ "$ctx" -gt 0 ] 2>/dev/null; then
    cpct=$(( ctx * 100 / 200000 ))
    segments+=("$(pct_color "$cpct")ctx ${cpct}%${C_RESET}")
  fi
fi

# git branch
if [ -n "$cwd" ] && command -v git >/dev/null 2>&1; then
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ -n "$branch" ] && segments+=("${C_MAGENTA} ${branch}${C_RESET}")
fi

# ` │ ` 連結で出力
out=""
for s in "${segments[@]}"; do
  if [ -z "$out" ]; then out="$s"; else out="${out} ${C_DIM}│${C_RESET} ${s}"; fi
done
printf '%s' "$out"
