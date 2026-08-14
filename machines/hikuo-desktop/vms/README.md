# hikuo-vwin

VMware Workstation の置き換えとして、GTX 1050 Ti をパススルーした Windows 11 VM を
KVM/QEMU + libvirt + VFIO + Looking Glass で動かす。

## 構成の分担

| 層 | 実体 | 管理 |
|---|---|---|
| ホスト (VFIO, kvmfr, libvirtd, ISO 配置, virsh define) | `modules/vm/nixos.nix`, `machines/hikuo-desktop/modules/vm.nix` | NixOS |
| VM ハードウェア構成 | `hikuo-vwin.xml` | git（libvirt XML そのまま） |
| Windows 無人インストール | `hikuo-vwin/autounattend.xml` | git（公式形式そのまま） |
| Windows のディスク中身 | `/var/lib/libvirt/images/hikuo-vwin.qcow2` | 管理しない（再インストール可能） |
| NVRAM | `/var/lib/libvirt/qemu/nvram/hikuo-vwin_VARS.fd` | 管理しない（実行時状態） |

virt-manager は確認・操作用であって source of truth ではない。XML を変えたら
`nixos-rebuild switch` で `hikuo-vwin-define.service` が再実行され、定義が上書きされる。
逆に virt-manager で加えた変更は次の rebuild か再起動で消える。

秘密の値は一切扱わない。プロダクトキーはインストール中に手入力し、ローカルアカウントの
パスワードは空にしてある。空パスワードは既定ポリシー *Accounts: Limit local account use
of blank passwords to console logon only* によりネットワークログオン（RDP・SMB）では
使えないので、効くのはこの VM のコンソールだけ。

## 初回の準備（一度だけ）

ドメイン XML は固定パスを参照する。ファイル名を変えずに置く。

```bash
sudo mkdir -p /var/lib/libvirt/iso
sudo install -m 0644 ~/Downloads/Win11_25H2_Japanese_x64_v2.iso /var/lib/libvirt/iso/windows11.iso
sudo install -m 0644 ~/Downloads/virtio-win-0.1.285.iso        /var/lib/libvirt/iso/virtio-win.iso
sudo nixos-rebuild switch --flake ./machines/hikuo-desktop
```

`hikuo-vwin-define.service` が qcow2 を 128GiB で作ってドメインを定義する。
autounattend ISO は derivation で作られ、`/var/lib/libvirt/iso/` へリンクされる。

## インストール

```bash
virsh -c qemu:///system start hikuo-vwin
virt-manager   # SPICE コンソールで進行を見る
```

ディスクが boot order 1 なので、空のうちは CD へ落ちてインストーラが起動し、
インストール後は CD を経由せず直接 Windows が起動する。

手で触るのは**プロダクトキー入力とエディション選択の 2 画面**、および 2 回目のログオンで
出る **UAC の確認 1 回**だけ。それ以外は無人で通る。

| 段階 | 内容 |
|---|---|
| インストール | 言語・キーボード、ライセンス条項、ディスク構成、インストール |
| OOBE | ローカルユーザー `hikuo` を作成し、自動ログイン |
| 初回ログオン | 自動ログインの恒久化、virtio-win guest tools（VirtIO ドライバ・QEMU guest agent・SPICE vdagent）を導入 |
| 2 回目のログオン | winget で Google Chrome、Tailscale、WinFsp を導入 |
| 3 回目の起動 | VirtioFS の共有フォルダが `Z:` に出る |

winget を初回ログオンではなく 2 回目に回しているのは、初回ログオンの時点では
App Installer の実行エイリアスがまだ PATH に載っておらず `winget` が見つからないため。
RunOnce は昇格されないので、マシン全体へインストールする際に UAC が 1 度出る。

ログの場所は段階で違う。

- 初回ログオン: `C:\Windows\Panther\unattend-guest-tools.log`
- 2 回目のログオン: `%LOCALAPPDATA%\Temp\unattend-chrome.log`, `unattend-tailscale.log`,
  `unattend-winfsp.log`

## 共有フォルダ

ホストの `/mnt/vm-shared` が VirtioFS でゲストの `Z:` に出る。SMB は使わない。
読み書きとも可能で、ゲストから作ったファイルはホスト側で `hikuo:users` として見える
（virtiofsd が root で `accessmode='passthrough'` のため所有権が素通しになる）。

`Z:` が出ない場合は、ゲストで次を確認する。

```
sc query VirtioFsSvc
```

このサービスは `viofs` ドライバ（virtio-win guest tools が入れる）と **WinFsp**
（virtio-win には同梱されないので winget で入れる）の両方が揃って初めて起動する。
自動インストールでは WinFsp が 2 回目のログオンで入るため、サービスが実際に上がるのは
3 回目の起動から。手で早めるなら WinFsp を入れた直後に `sc start VirtioFsSvc` でよい。

## インストール後の手動手順

自動化しないと決めたのは、公式のサイレントインストーラが無いか、バージョンを
クライアント側と厳密に合わせる必要があるものだけ。

### NVIDIA ドライバ

Windows Update が GTX 1050 Ti のドライバを自動で入れる。入らなければ
[nvidia.com](https://www.nvidia.com/Download/index.aspx) から手動で導入する。
入るまでパススルー GPU は「基本ディスプレイアダプター」のままで、
Looking Glass の映像も出ない。

### ディスプレイのプライマリ設定

エミュレート VGA とパススルーした 1050 Ti の 2 つが見える状態になる。Windows は
VGA をプライマリにしがちで、そのままだとゲームが VGA 側で動いて Looking Glass に
何も映らない。**ディスプレイ設定で 1050 Ti 側をプライマリにする。**
VGA はドライバが壊れたときの保守用コンソールとして残しておく。

### Looking Glass host

ホスト側クライアントとバージョンを一致させる必要がある（現在 **B7**）。

1. ゲストの Chrome で <https://looking-glass.io/artifact/B7/host> を開いて zip を取得
2. `looking-glass-host-setup.exe` を実行。IVSHMEM ドライバごと入り、サービスとして常駐する

### Tailscale へのログイン

`tailscale up` はブラウザ認証が要るので手動。

### 自動ログインの確認

`LogonCount` の恒久化はレジストリ側で行っている。一度再起動して、ログイン画面が
出ずにデスクトップまで来ることを確認する。

## 日常の起動

```bash
virsh -c qemu:///system start hikuo-vwin
looking-glass-client -f /dev/kvmfr0
```

音声とクリップボードは SPICE 側で扱う。virt-manager の SPICE ウィンドウを
開いたままにしておくと、Looking Glass で映像を見つつクリップボードが同期される。
コントローラやヘッドセットは virt-manager の *USB デバイスをリダイレクト* から渡す
（USB コントローラが `00:14.0` の 1 つだけで、丸ごとのパススルーはできないため）。

vCPU は pinning のみで、ホストから隔離はしていない。**VM を動かしている間は
`nixos-rebuild` のような重いビルドを走らせない。**

## 作り直す

qcow2 だけ消すと NVRAM に前回の Windows Boot Manager エントリが残り、起動の挙動が
読めなくなる。NVRAM ごと消すこと。

```bash
virsh -c qemu:///system undefine hikuo-vwin --nvram
sudo rm /var/lib/libvirt/images/hikuo-vwin.qcow2
sudo systemctl restart hikuo-vwin-define
```

## 現状の制限

- Secure Boot は「対応ファームウェアで UEFI 起動する」までで、鍵を登録していないので
  実際には有効になっていない。Windows 11 の要件は満たす。実 Secure Boot にするなら
  `pkgs.OVMFFull.fd` の `OVMF_VARS.ms.fd` を固定パスへリンクして `enrolled-keys=yes`
  にすればよいが、IVSHMEM ドライバが署名検証で弾かれるリスクがある
- アンチチート回避や VM 隠蔽は実装しない
- 4K は狙わない。kvmfr のバッファは FHD 前提の 128MiB
