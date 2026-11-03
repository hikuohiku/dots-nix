{ config, lib, pkgs, ... }:
let
  # ドメイン XML が参照する ISO の固定パス。ISO 自体は git 管理しない。
  isoDir = "/var/lib/libvirt/iso";
  domainXml = ../vms/hikuo-vwin.xml;

  # answer file に秘密の値が無いので、ISO は純粋な derivation で作れる。
  autounattendIso =
    pkgs.runCommand "hikuo-vwin-autounattend.iso"
      {
        nativeBuildInputs = [ pkgs.xorriso ];
      }
      ''
        mkdir media
        cp ${../vms/hikuo-vwin/autounattend.xml} media/Autounattend.xml
        xorriso -as mkisofs -quiet -J -joliet-long -iso-level 3 \
          -V AUTOUNATTEND -o "$out" media
      '';
in
{
  config = lib.mkIf config.mymodule.apps.vm.enable {
    systemd.tmpfiles.rules = [
      "d ${isoDir} 0755 root root -"
      # store のパスは編集のたびに変わるので、固定パスからリンクする。
      "L+ ${isoDir}/hikuo-vwin-autounattend.iso - - - - ${autounattendIso}"
    ];

    systemd.services.hikuo-vwin-define = {
      description = "Define the hikuo-vwin libvirt domain";
      wantedBy = [ "multi-user.target" ];
      wants = [ "libvirtd.service" ];
      after = [ "libvirtd.service" ];
      restartTriggers = [ domainXml ];
      path = [ pkgs.libvirt ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -euo pipefail
        virsh -c qemu:///system define ${domainXml}
      '';
    };

    # ホストのスリープをまたいで hikuo-vwin を安全に停止・再開する。
    # NVMe をパススルーしたゲストの稼働中にホストがスリープすると復帰後にフリーズすることがあるため、
    # スリープ前に停止し、復帰後に再起動する。実機起動とディスクを共用しており休止状態は使えない。
    systemd.services.hikuo-vwin-sleep = {
      description = "Shut down hikuo-vwin across host sleep";
      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      wants = [ "libvirtd.service" ];
      after = [ "libvirtd.service" ];
      unitConfig.StopWhenUnneeded = true;
      path = [ pkgs.libvirt ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        RuntimeDirectory = "hikuo-vwin-sleep";
        TimeoutStartSec = 180;
      };
      script = ''
        state() { virsh -c qemu:///system domstate hikuo-vwin; }
        [ "$(state)" != "shut off" ] || exit 0
        touch "$RUNTIME_DIRECTORY/restart"
        virsh -c qemu:///system shutdown hikuo-vwin || true
        for _ in $(seq 120); do
          [ "$(state)" != "shut off" ] || exit 0
          sleep 1
        done
        # ゲストを稼働させたままスリープさせないため、正常終了しなければ強制停止する。
        echo "hikuo-vwin did not shut down in time, forcing it off"
        virsh -c qemu:///system destroy hikuo-vwin
      '';
      preStop = ''
        [ ! -e "$RUNTIME_DIRECTORY/restart" ] || virsh -c qemu:///system start hikuo-vwin
      '';
    };

    # ゲストの OpenSSH Server へ virbr0 で入る（名前は libvirt NSS が引く）。tailnet は
    # ゲストの Tailscale がログイン前に繋がらないので使わない。Windows の OpenSSH は
    # ML-KEM 未対応で毎回警告が出るので黙らせる。
    programs.ssh.extraConfig = ''
      Host hikuo-vwin
        User hikuo
        WarnWeakCrypto no-pq-kex
        ControlMaster auto
        ControlPath ~/.ssh/cm-%C
        ControlPersist 10m
    '';

    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "vwin";
        runtimeInputs = [
          pkgs.libvirt
          pkgs.openssh
          pkgs.mutagen
          pkgs.git
        ];
        # リモートのコマンド文字列は意図的にホスト側で展開して組み立てる。
        excludeShellChecks = [ "SC2029" ];
        text = builtins.readFile ../vms/vwin.sh;
      })
    ];

    # vwin cpu isolate がホストのプロセスを vCPU と重複しない CPU に寄せる
    # （AllowedCPUs の変更）操作を、libvirtd グループに root 権限なしで許可する。
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        var unit = action.lookup("unit");
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("verb") == "set-property" &&
            (unit == "system.slice" || unit == "user.slice" || unit == "init.scope") &&
            subject.isInGroup("libvirtd")) {
          return polkit.Result.YES;
        }
      });
    '';

    # VM 停止時に vwin cpu isolate による CPU 隔離を解除する。
    virtualisation.libvirtd.hooks.qemu.cpu-isolate = pkgs.writeShellScript "cpu-isolate" ''
      [ "$1" = hikuo-vwin ] && [ "$2" = release ] || exit 0
      for unit in system.slice user.slice init.scope; do
        ${pkgs.systemd}/bin/systemctl set-property --runtime "$unit" AllowedCPUs=0-$(($(nproc --all) - 1))
      done
    '';
  };
}
