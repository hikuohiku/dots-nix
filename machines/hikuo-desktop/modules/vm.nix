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

    # VM が動いている間だけホストのプロセスを vCPU と重ならない CPU に寄せる。
    # XML の emulatorpin と同じ 0,1,6,7（コア 0,1 の両スレッド）。machine.slice は
    # 触らないので vCPU スレッドは pinning どおり動く。--runtime なので再起動で戻る。
    virtualisation.libvirtd.hooks.qemu.cpu-isolate = pkgs.writeShellScript "cpu-isolate" ''
      [ "$1" = hikuo-vwin ] || exit 0
      case "$2" in
        prepare) cpus=0,1,6,7 ;;
        release) cpus=0-11 ;;
        *) exit 0 ;;
      esac
      for unit in system.slice user.slice init.scope; do
        ${pkgs.systemd}/bin/systemctl set-property --runtime "$unit" AllowedCPUs="$cpus"
      done
    '';
  };
}
