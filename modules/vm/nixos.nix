{ config, lib, pkgs, ... }:
let
  qemu-wrapper = pkgs.writeShellScript "qemu-system-x86_64-gl" ''
    export __EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d
    exec ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 "$@"
  '';
  qemu-wrapped = pkgs.runCommand "qemu-kvm-gl-${pkgs.qemu_kvm.version}" {
    inherit (pkgs.qemu_kvm) version passthru;
  } ''
    mkdir -p $out/bin
    for dir in ${pkgs.qemu_kvm}/*; do
      name=$(basename "$dir")
      [ "$name" = "bin" ] && continue
      ln -s "$dir" "$out/$name"
    done
    for f in ${pkgs.qemu_kvm}/bin/*; do
      name=$(basename "$f")
      if [ "$name" = "qemu-system-x86_64" ]; then
        ln -s ${qemu-wrapper} "$out/bin/$name"
      else
        ln -s "$f" "$out/bin/$name"
      fi
    done
  '';
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
