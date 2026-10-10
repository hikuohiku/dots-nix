#!/usr/bin/env bash
# Claude Code statusline (2 行)。
# stdin の JSON を jq で読み、モデル / ディレクトリ / git と、
# context・5h・7d リミットのゲージを出力する。
# context は transcript ではなく .context_window から取る (tac は macOS に無い)。
# 依存: jq, git。

set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0

# 値は \x1f 区切り 1 行で受ける。tab など IFS 空白文字だと連続区切りが畳まれ、
# 空フィールドで位置がずれる。
S=$'\x1f'
IFS="$S" read -r model ctx_pct ctx_used ctx_size five_pct five_reset seven_pct \
  cost added removed cwd effort agent branch_wt pr_num < <(
  jq -r --arg s "$S" '[
    (.model.display_name // ""),
    (.context_window.used_percentage // ""),
    (.context_window.total_input_tokens // ""),
    (.context_window.context_window_size // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.cost.total_cost_usd // ""),
    (.cost.total_lines_added // ""),
    (.cost.total_lines_removed // ""),
    (.workspace.current_dir // .cwd // ""),
    (.effort.level // ""),
    (.agent.name // ""),
    (.worktree.branch // ""),
    (.pr.number // "")
  ] | map(tostring) | join($s)' 2>/dev/null
)

R=$'\033[0m'; D=$'\033[2m'; B=$'\033[1m'
GREEN=$'\033[38;5;114m'; YELLOW=$'\033[38;5;179m'; RED=$'\033[38;5;174m'
CYAN=$'\033[38;5;110m'; MAGENTA=$'\033[38;5;176m'; GREY=$'\033[38;5;245m'

# 使用率 -> 色 (<50 緑 / <80 黄 / それ以上 赤)
pct_color() {
  local p=${1%%.*}
  case $p in ''|*[!0-9]*) printf '%s' "$D"; return;; esac
  if   [ "$p" -lt 50 ]; then printf '%s' "$GREEN"
  elif [ "$p" -lt 80 ]; then printf '%s' "$YELLOW"
  else                       printf '%s' "$RED"; fi
}

# 使用率ゲージ。1/8 幅ブロックで端数も出す。
gauge() {
  local p=${1%%.*} w=${2:-10} i eighths full part out='' c
  case $p in ''|*[!0-9]*) p=0;; esac
  c=$(pct_color "$p")
  eighths=$(( p * w * 8 / 100 )); full=$(( eighths / 8 )); part=$(( eighths % 8 ))
  for (( i = 0; i < full; i++ )); do out="${out}█"; done
  if [ "$full" -lt "$w" ] && [ "$part" -gt 0 ]; then
    out="${out}$(printf '%s' '▏▎▍▌▋▊▉' | cut -c "$part")"
    full=$(( full + 1 ))
  fi
  if [ "$full" -lt "$w" ]; then
    out="$out$D"
    for (( i = full; i < w; i++ )); do out="${out}░"; done
  fi
  printf '%s%s%s' "$c" "$out" "$R"
}

# 1234567 -> 1.2M / 12345 -> 12k
human() {
  local n=${1%%.*}
  case $n in ''|*[!0-9]*) return;; esac
  if   [ "$n" -ge 1000000 ]; then printf '%d.%dM' $(( n / 1000000 )) $(( n % 1000000 / 100000 ))
  elif [ "$n" -ge 1000 ];    then printf '%dk' $(( n / 1000 ))
  else printf '%d' "$n"; fi
}

# 引数を ` │ ` で連結 (空は捨てる)
join_segs() {
  local out='' s
  for s in "$@"; do
    [ -z "$s" ] && continue
    if [ -z "$out" ]; then out="$s"; else out="$out ${D}│${R} $s"; fi
  done
  printf '%s' "$out"
}

# --- 1 行目: モデル / ディレクトリ / git ---
L1=()
[ -n "$model" ] && L1+=("${CYAN}${B}󰚩 ${model}${R}${effort:+${D} ${effort}${R}}")
[ -n "$agent" ] && L1+=("${MAGENTA}󰭹 ${agent}${R}")
[ -n "$cwd" ] && L1+=("${GREY} ${cwd/#$HOME/'~'}${R}")

if [ -n "$cwd" ] && command -v git >/dev/null 2>&1; then
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=''
    git -C "$cwd" diff --quiet --ignore-submodules HEAD 2>/dev/null || dirty="${YELLOW}●${R}"
    seg="${MAGENTA} ${branch}${R}${dirty}"
    [ -n "$branch_wt" ] && [ "$branch_wt" != "$branch" ] && seg="$seg ${D}(wt)${R}"
    [ -n "$pr_num" ] && seg="$seg ${D}#${pr_num}${R}"
    L1+=("$seg")
  fi
fi

# --- 2 行目: context / リミット / コスト ---
L2=()
if [ -n "$ctx_pct" ]; then
  seg="${D}ctx${R} $(gauge "$ctx_pct" 12) $(pct_color "$ctx_pct")$(printf '%3d%%' "${ctx_pct%%.*}")${R}"
  [ -n "$ctx_used" ] && [ -n "$ctx_size" ] &&
    seg="$seg ${D}$(human "$ctx_used")/$(human "$ctx_size")${R}"
  L2+=("$seg")
fi

if [ -n "$five_pct" ]; then
  p=$(printf '%.0f' "$five_pct" 2>/dev/null || printf '%s' "$five_pct")
  seg="${D}5h${R} $(gauge "$p" 6) $(pct_color "$p")$(printf '%3d%%' "$p")${R}"
  r=$(date -r "${five_reset%%.*}" +%H:%M 2>/dev/null)
  [ -n "$r" ] && seg="$seg ${D}↻$r${R}"
  L2+=("$seg")
fi

if [ -n "$seven_pct" ]; then
  p=$(printf '%.0f' "$seven_pct" 2>/dev/null || printf '%s' "$seven_pct")
  L2+=("${D}7d${R} $(gauge "$p" 6) $(pct_color "$p")$(printf '%3d%%' "$p")${R}")
fi

[ -n "$cost" ] && L2+=("${GREEN}\$$(printf '%.2f' "$cost" 2>/dev/null)${R}")
if [ "${added:-0}" != "0" ] || [ "${removed:-0}" != "0" ]; then
  L2+=("${GREEN}+${added:-0}${R}${D}/${R}${RED}-${removed:-0}${R}")
fi

printf '%s' "$(join_segs "${L1[@]-}")"
[ ${#L2[@]} -gt 0 ] && printf '\n%s' "$(join_segs "${L2[@]}")"

exit 0
