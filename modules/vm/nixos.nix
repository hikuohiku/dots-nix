{ config, lib, pkgs, ... }:
let
  qemu-gl-wrapper = pkgs.writeShellScript "qemu-system-x86_64-gl" ''
    export __EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d
    exec ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 "$@"
  '';
in
{
  config = lib.mkIf config.mymodule.apps.vm.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        verbatimConfig = ''
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm",
            "/dev/rtc", "/dev/hpet",
            "/dev/dri/renderD128"
          ]
        '';
      };
    };

    systemd.services.libvirtd-config.postStart = ''
      ln -sf ${qemu-gl-wrapper} /run/libvirt/nix-emulators/qemu-system-x86_64
    '';

    networking.firewall.trustedInterfaces = [ "virbr0" ];

    programs.virt-manager.enable = true;

    environment.systemPackages = [
      pkgs.spice-gtk
    ];
  };
}
