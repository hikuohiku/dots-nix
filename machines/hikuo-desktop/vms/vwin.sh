# hikuo-vwin（Windows VM）をホストから操作する。止まっていれば起動し、SSH が通るまで待つ。
#   vwin                 対話シェル（pwsh）
#   vwin <cmd...>        pwsh でコマンドを実行する
#   vwin run <cmd...>    カレントの git リポジトリを C:\src\<名前> へ同期し、そこで実行する
#   vwin sync [stop]     同期だけする / 同期セッションを止める
# コマンドは 1 つの pwsh スクリプト文字列として渡る（管理者権限、UTF-8）。
# 同期はホストを正とする片方向ミラーで、Windows 側の変更は次の同期で消える。
# node_modules, target, obj, .venv, __pycache__ は同期せず Windows 側に残る。
# 成果物は scp hikuo-vwin:C:/src/<名前>/... で取り出す。
host=hikuo-vwin

# pwsh -c は native コマンドの終了コードを 1 に潰すので、明示的に返す。
remote() {
  exec ssh "$host" "$1; if (-not \$?) { exit \$(if (\$LASTEXITCODE) { \$LASTEXITCODE } else { 1 }) }"
}

up() {
  ssh -o ConnectTimeout=3 -o BatchMode=yes "$host" exit 2>/dev/null && return
  if [ "$(virsh -c qemu:///system domstate "$host")" != running ]; then
    echo "vwin: $host を起動します" >&2
    virsh -c qemu:///system start "$host" >/dev/null
  fi
  for _ in $(seq 100); do
    ssh -o ConnectTimeout=3 -o BatchMode=yes "$host" exit 2>/dev/null && return
    sleep 3
  done
  echo "vwin: $host に SSH できません" >&2
  exit 1
}

# 無視するのは OS ごとに中身が違う依存やビルド出力。.git は Windows 側の git 操作と
# 食い合うので送らない。
sync() {
  repo=$(git rev-parse --show-toplevel)
  name=$(basename "$repo")
  session=vwin-$name
  if ! mutagen sync list "$session" >/dev/null 2>&1; then
    # mutagen は agent が無いことをエラー文言で判定するが、日本語の pwsh では
    # 判定できず自動で入れられない。同梱の Windows 版を自分で置く。
    agent=.mutagen/agents/$(mutagen version)/mutagen-agent.exe
    if [ "$(ssh "$host" "New-Item -Force -ItemType Directory C:/src, $(dirname "$agent") | Out-Null; Test-Path $agent")" != True ]; then
      tmp=$(mktemp -d)
      tar xzf "$(dirname "$(readlink -f "$(command -v mutagen)")")/../libexec/mutagen-agents.tar.gz" -C "$tmp" windows_amd64
      scp -q "$tmp/windows_amd64" "$host:$agent"
      rm -rf "$tmp"
    fi
    mutagen sync create --name "$session" --mode one-way-replica --ignore-vcs \
      --ignore node_modules --ignore target --ignore obj --ignore .venv \
      --ignore __pycache__ --ignore .direnv --ignore result \
      "$repo" "$host:C:/src/$name" >&2
  fi
  mutagen sync flush "$session" >&2
}

case "${1-}" in
  -h | --help)
    sed -n '/^# hikuo-vwin/,/^host=/s/^# //p' "$0"
    ;;
  "")
    up
    exec ssh "$host"
    ;;
  run)
    shift
    up
    sync
    remote "Set-Location -ErrorAction Stop C:/src/$name; $*"
    ;;
  sync)
    if [ "${2-}" = stop ]; then
      mutagen sync terminate "vwin-$(basename "$(git rev-parse --show-toplevel)")"
    else
      up
      sync
    fi
    ;;
  *)
    up
    remote "$*"
    ;;
esac
