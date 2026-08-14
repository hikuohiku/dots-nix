{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.vm.enable {
    boot = {
      kernelParams = [
        "intel_iommu=on"
        "iommu=pt"
        # GTX 1050 Ti and its HDMI audio function.
        "vfio-pci.ids=10de:1c82,10de:0fb9"
        # Looking Glass の共有バッファ。FHD なら 128MiB で足りる。
        "kvmfr.static_size_mb=128"
      ];
      initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
        "kvmfr"
      ];
      extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
    };

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        verbatimConfig = ''
          namespaces = []
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom", "/dev/ptmx",
            "/dev/kvm", "/dev/kqemu", "/dev/rtc", "/dev/hpet",
            "/dev/vfio/vfio", "/dev/kvmfr0"
          ]
        '';
      };
    };

    networking.firewall.trustedInterfaces = [ "virbr0" ];

    programs.virt-manager.enable = true;

    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "kvmfr-udev-rules";
        text = ''
          SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660", TAG+="uaccess"
        '';
        destination = "/etc/udev/rules.d/70-kvmfr.rules";
      })
    ];

    environment.systemPackages = [
      pkgs.looking-glass-client
      pkgs.spice-gtk
      pkgs.freerdp
    ];
  };
}
