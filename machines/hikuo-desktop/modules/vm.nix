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
  };
}
