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

    # ゲストのアイドル時はホストに CPU を譲り、CPU 競合時は VM を優先する。
    systemd.slices.machine.sliceConfig.CPUWeight = 1000;

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
