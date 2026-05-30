{ config, lib, pkgs, ... }:
let
  qemu-gl = pkgs.writeShellScriptBin "qemu-system-x86_64" ''
    export __EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d
    exec ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 "$@"
  '';
  qemu-wrapped = pkgs.symlinkJoin {
    name = "qemu-kvm-gl";
    paths = [ qemu-gl pkgs.qemu_kvm ];
    passthru = pkgs.qemu_kvm.passthru // {
      inherit (pkgs.qemu_kvm) version;
    };
    inherit (pkgs.qemu_kvm) version;
  };
in
{
  config = lib.mkIf config.mymodule.apps.vm.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = qemu-wrapped;
        swtpm.enable = true;
      };
    };

    networking.firewall.trustedInterfaces = [ "virbr0" ];

    programs.virt-manager.enable = true;

    environment.systemPackages = [
      pkgs.spice-gtk
    ];
  };
}
