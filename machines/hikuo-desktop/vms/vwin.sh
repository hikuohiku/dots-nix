# hikuo-vwin（Windows VM）をホストから操作する。停止中は自動で起動し、SSH が通るまで待機する。
#   vwin                 対話シェル（pwsh）を起動する
#   vwin <cmd...>        pwsh でコマンドを実行する
#   vwin run <cmd...>    カレントの git リポジトリを C:\src\<名前> へ同期し、そのディレクトリで実行する
#   vwin sync [stop]     同期のみを実行する / 同期セッションを終了する
#                        <名前> は <リポジトリ>-<worktree>（main checkout では <リポジトリ>）
#   vwin cpu [isolate|share]  CPU 割り当てを表示する / ホストを vCPU と別コアに隔離する /
#                        共有に戻す。通常は共有で、VM 停止時にも自動で共有に戻る
# コマンドは 1 つの pwsh スクリプト文字列として渡る（管理者権限、UTF-8）。
# 同期はホストを正とする片方向ミラーで、Windows 側で変更したファイルは元に戻り、追加したファイルは削除される。
# node_modules, target, obj, bin, .venv, __pycache__, .terraform は同期対象外として Windows 側に残る。
# 成果物は scp hikuo-vwin:C:/src/<名前>/... で取得する。
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

# カレントの git リポジトリの同期先と同期セッションを決定する。
# リポジトリ名は main checkout のディレクトリ名に基づき、remote の有無に依存しない。
resolve() {
  repo=$(git rev-parse --show-toplevel)
  name=$(basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")")
  worktree=$(basename "$repo")
  [ "$worktree" = "$name" ] || name=$name-$worktree
  session=vwin-$name
  # a-b の c と a の b-c、別 org の同名リポジトリのようにセッション名が重複する場合がある。
  # 別のリポジトリの同期先で実行したり、そのセッションを停止したりしないよう、ここで中断する。
  synced=$(mutagen sync list --template '{{ range . }}{{ .Alpha.Path }}{{ end }}' "$session" 2>/dev/null) || synced=
  if [ -n "$synced" ] && [ "$synced" != "$repo" ]; then
    echo "vwin: $session は $synced の同期セッションで、$repo には使えない" >&2
    exit 1
  fi
}

# OS 依存のファイルやビルド出力は同期対象外とする。
# .git は Windows 側の git 操作との競合を防ぐため転送しない。
sync() {
  resolve
  if [ -z "$synced" ]; then
    # mutagen は agent の不在をエラー文言で判定するが、日本語環境の pwsh では判定できず自動配置に失敗するため、
    # 本スクリプトで同梱の Windows 版 agent を配置する。稼働中の agent は上書きできないため、既にあれば配置しない。
    # なお、pwsh の出力は CRLF を含む。
    agent=.mutagen/agents/$(mutagen version)/mutagen-agent.exe
    if [ "$(ssh "$host" "New-Item -Force -ItemType Directory C:/src, $(dirname "$agent") | Out-Null; Test-Path $agent" | tr -d '\r')" != True ]; then
      tmp=$(mktemp -d)
      tar xzf "$(dirname "$(readlink -f "$(command -v mutagen)")")/../libexec/mutagen-agents.tar.gz" -C "$tmp" windows_amd64
      scp -q "$tmp/windows_amd64" "$host:$agent"
      rm -rf "$tmp"
    fi
    mutagen sync create --name "$session" --mode one-way-replica --ignore-vcs \
      --ignore node_modules --ignore target --ignore obj --ignore bin --ignore .venv \
      --ignore __pycache__ --ignore .direnv --ignore result --ignore .terraform \
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
  cpu)
    case "${2-}" in
      isolate) cpus=0,6 ;;
      share) cpus=0-$(($(nproc --all) - 1)) ;;
      "")
        if [ "$(systemctl show -P AllowedCPUs user.slice)" = "0 6" ]; then echo isolate; else echo share; fi
        exit
        ;;
      *)
        echo "vwin: cpu には isolate か share を指定する" >&2
        exit 2
        ;;
    esac
    for unit in system.slice user.slice init.scope; do
      systemctl set-property --runtime "$unit" AllowedCPUs="$cpus"
    done
    ;;
  sync)
    case "$*" in
      sync)
        up
        sync
        ;;
      "sync stop")
        resolve
        mutagen sync terminate "$session"
        ;;
      *)
        echo "vwin: sync に指定できるのは stop だけ" >&2
        exit 2
        ;;
    esac
    ;;
  *)
    up
    remote "$*"
    ;;
esac
