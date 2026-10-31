# hikuo-vwin

VMware Workstation の置き換えとして、GTX 1050 Ti をパススルーした Windows 11 VM を
KVM/QEMU + libvirt + VFIO + Looking Glass で動かす。

## 構成の分担

| 層 | 実体 | 管理 |
|---|---|---|
| ホスト (VFIO, kvmfr, libvirtd, ISO 配置, virsh define) | `modules/vm/nixos.nix`, `machines/hikuo-desktop/modules/vm.nix` | NixOS |
| VM ハードウェア構成 | `hikuo-vwin.xml` | git（libvirt XML そのまま） |
| Windows 無人インストール | `hikuo-vwin/autounattend.xml` | git（公式形式そのまま） |
| Windows のディスク中身（C: と G:） | VM 用 NVMe（PCI `04:00.0` をパススルー） | 管理しない（再インストール可能） |
| NVRAM | `/var/lib/libvirt/qemu/nvram/hikuo-vwin_VARS.fd` | 管理しない（実行時状態） |

virt-manager は確認・操作用であって source of truth ではない。XML を変えたら
`nixos-rebuild switch` で `hikuo-vwin-define.service` が再実行され、定義が上書きされる。
逆に virt-manager で加えた変更は次の rebuild か再起動で消える。

秘密の値は一切扱わない。プロダクトキーはインストール中に手入力し、ローカルアカウントの
パスワードはインストール時点では空にしてある（後から設定済み。自動ログインは
「自動ログインの確認」を参照）。ホストからの操作は SSH の鍵認証で、パスワードは使わない。

## 初回の準備（一度だけ）

ドメイン XML は固定パスを参照する。ファイル名を変えずに置く。

```bash
sudo mkdir -p /var/lib/libvirt/iso
sudo install -m 0644 ~/Downloads/Win11_25H2_Japanese_x64_v2.iso /var/lib/libvirt/iso/windows11.iso
sudo install -m 0644 ~/Downloads/virtio-win-0.1.285.iso        /var/lib/libvirt/iso/virtio-win.iso
sudo nixos-rebuild switch --flake ./machines/hikuo-desktop
```

`hikuo-vwin-define.service` がドメインを定義する。
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

## ディスク

VM 用 NVMe（931GB）を丸ごと渡し、C:（400GB）とゲーム用の G:（`Games`、残り）に分けている。
回復環境は C: の中（`reagentc` で移動済み）で、回復パーティションは無い。

OS ディスクの NVMe は **`vfio-pci.ids` で束縛できない。** 2 枚の SSD は同一モデルで PCI ID も同じ `c0a9:540a` のため、
ID で束縛すると NixOS の root ディスクまで vfio に持っていかれる。PCI アドレス指定の
`managed='yes'` で libvirt に着脱させること。

virtio ディスクで入れた Windows を NVMe へ移すと、自動修復に落ちて起動しない。Windows は
使っていないストレージドライバを `stornvme\StartOverride`（`0=3`）で無効化しているため。
virtio のまま起動してこのキーを消してから切り替える。

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
3. `C:\Program Files\Looking Glass (host)\looking-glass-host.ini` を置く。1050 Ti は
   チップセット経由の PCIe x4 で、4K@120 の取り込みは帯域に収まらないため縮小して送る

   ```ini
   [d12]
   downsample=3840x2160:2560x1440
   allowRGB24=yes
   ```

4. サービスは NVIDIA ドライバより先に起動すると GPU を見つけられず終了する。
   失敗時に再起動させる: `sc.exe failure "Looking Glass (host)" reset= 86400 actions= restart/10000/restart/10000/restart/30000`
   と `sc.exe failureflag "Looking Glass (host)" 1`

### 性能まわり

- **Hyper-V を止める。** WSL2 用の「仮想マシン プラットフォーム」があると Windows が
  Hyper-V 上で動き、KVM の上で入れ子になって UI が目に見えて重くなる。
  `Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform`、
  `bcdedit /set {current} hypervisorlaunchtype off`、DeviceGuard の
  `EnableVirtualizationBasedSecurity=0`。WSL2 は使えなくなる
- NVIDIA コントロールパネルの電源管理モードを「パフォーマンス最大化を優先」。省電力だと
  PCIe も Gen1 まで落ち、取り込みが追いつかない
- 1050 Ti の HDMI オーディオを MSI にする（`Device Parameters\Interrupt Management\MessageSignaledInterruptProperties` の `MSISupported=1`）
- 電源プランは高パフォーマンス、高速スタートアップは無効（実機起動と共用するため）

### SSH（ホストからの操作用）

ホストの `vwin` が使う。ゲストで管理者として:

1. `Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0`、PowerShell 7 の MSI を導入
2. ホストの `~/.ssh/id_ed25519.pub` を `C:\ProgramData\ssh\administrators_authorized_keys` に置き、
   `icacls <file> /inheritance:r /grant Administrators:F /grant SYSTEM:F`
3. `HKLM:\SOFTWARE\OpenSSH` の `DefaultShell` を `C:\Program Files\PowerShell\7\pwsh.exe` にし、
   `sshd` を自動起動にする
4. virbr0 側の NIC は Public 扱いで既定の許可ルール（Private のみ）に当たらない。
   `New-NetFirewallRule -Name OpenSSH-Server-In-libvirt -Direction Inbound -Protocol TCP -LocalPort 22 -RemoteAddress 192.168.122.1 -Profile Any -Action Allow`
5. `$PSHOME\profile.ps1` で `[Console]::InputEncoding`・`OutputEncoding`・`$OutputEncoding` を
   BOM なし UTF-8 にする。システム全体の UTF-8 化（ベータ）は古いゲームを壊すので使わない

### Tailscale へのログイン

`tailscale up --unattended` はブラウザ認証が要るので手動。`--unattended` が無いと
hikuo がサインインしている間しか繋がらない（後からなら `tailscale set --unattended`）。

### 自動ログインの確認

`LogonCount` の恒久化はレジストリ側で行っている。一度再起動して、ログイン画面が
出ずにデスクトップまで来ることを確認する。

パスワードを設定・変更すると Windows が自動ログインを外す。その場合は Sysinternals の
Autologon で入れ直す（パスワードは LSA に暗号化して保存される）。

## 日常の起動

```bash
virsh -c qemu:///system start hikuo-vwin
looking-glass-client -f /dev/kvmfr0
```

音声とクリップボードは SPICE 側で扱う。virt-manager の SPICE ウィンドウを
開いたままにしておくと、Looking Glass で映像を見つつクリップボードが同期される。
コントローラやヘッドセットは virt-manager の *USB デバイスをリダイレクト* から渡す
（USB コントローラが `00:14.0` の 1 つだけで、丸ごとのパススルーはできないため）。

VM が動いている間、ホストのプロセスは CPU 0,1,6,7 に寄せられる（libvirt hook の
`cpu-isolate`）。ホストは 4 スレッドしか使えないので、`nixos-rebuild` のような重いビルドは遅い。

## ホストから操作する

`vwin` で SSH 越しに pwsh を叩く（使い方は `vwin --help`）。VM が止まっていれば起動して待つ。
`vwin run <cmd>` はカレントの git リポジトリを mutagen で `C:\src\<名前>` へミラーしてから実行する。

名前は libvirt NSS が virbr0 側の IP に引く。tailnet の名前（MagicDNS）は使わない。
ゲストの Tailscale がログイン前やログアウト中は繋がらないため。

## 実機で起動する

同じ Windows を GRUB の *Windows (hikuo-vwin)* から実機でも起動できる
（`modules/host.nix` の `extraEntries`。ESP の FAT UUID を固定で書いている）。

- 高速スタートアップは無効のままにする。休止状態を別ハードで再開すると壊れる
- ファームウェアが VM 用 NVMe の *Windows Boot Manager* を自動登録して BootOrder の先頭に
  入れることがある。BIOS で無効にするか順序を戻す。エントリを消すと再登録で先頭に来る
- 再インストールで ESP を作り直したら `extraEntries` の UUID を更新する

## 作り直す

OS ディスクだけ消すと NVRAM に前回の Windows Boot Manager エントリが残り、起動の挙動が
読めなくなる。NVRAM ごと消すこと。

answer file は `DiskID 0` を `WillWipeDisk` して C: だけを作るので、**G: も消える**。
ゲームは入れ直す前提。インストール後に G: を作り直し、ESP の UUID が変わるので
`extraEntries` も更新する。

```bash
virsh -c qemu:///system undefine hikuo-vwin --nvram
sudo blkdiscard /dev/disk/by-path/pci-0000:04:00.0-nvme-1   # VM 停止中のみ
sudo systemctl restart hikuo-vwin-define
```

## 現状の制限

- Secure Boot は「対応ファームウェアで UEFI 起動する」までで、鍵を登録していないので
  実際には有効になっていない。Windows 11 の要件は満たす。実 Secure Boot にするなら
  `pkgs.OVMFFull.fd` の `OVMF_VARS.ms.fd` を固定パスへリンクして `enrolled-keys=yes`
  にすればよいが、IVSHMEM ドライバが署名検証で弾かれるリスクがある
- アンチチート回避や VM 隠蔽は実装しない
- 4K は狙わない。kvmfr のバッファは FHD 前提の 128MiB
