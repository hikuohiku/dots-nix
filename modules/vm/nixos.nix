{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.mymodule.apps.vm.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };

    networking.firewall.trustedInterfaces = [ "virbr0" ];

    systemd.services.libvirtd.environment = {
      __EGL_VENDOR_LIBRARY_DIRS = "/run/opengl-driver/share/glvnd/egl_vendor.d";
    };

    programs.virt-manager.enable = true;

    environment.systemPackages = [
      pkgs.spice-gtk
    ];
  };
}
