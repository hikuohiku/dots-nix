{ config, lib, pkgs, upstream, ... }:
let
  inherit (upstream.typeless) version src;
  unpacked = pkgs.stdenvNoCC.mkDerivation {
    pname = "typeless-unwrapped";
    inherit version src;
    nativeBuildInputs = [ pkgs.dpkg ];
    dontUnpack = true;
    installPhase = "dpkg-deb -x $src $out";
  };
  typeless = pkgs.buildFHSEnv {
    pname = "typeless";
    inherit version;
    targetPkgs = p: with p; [
      alsa-lib at-spi2-atk at-spi2-core atk cairo cups dbus expat gdk-pixbuf glib gtk3
      libdrm libgbm libglvnd libnotify libpulseaudio libsecret libxkbcommon mesa nspr nss
      pango stdenv.cc.cc.lib systemd zlib
      libx11 libxcb libxcomposite libxdamage libxext libxfixes libxi libxrandr libxrender
      libxscrnsaver libxtst
      acl procps util-linux wl-clipboard xdg-utils
    ];
    # 上流のパッケージが /opt/Typeless への配置を前提としているため。
    extraBwrapArgs = [ "--ro-bind ${unpacked}/opt/Typeless /opt/Typeless" ];
    runScript = "/opt/Typeless/typeless";
    extraInstallCommands = ''
      mkdir -p $out/share
      cp -r ${unpacked}/usr/share/icons $out/share/
      install -Dm644 ${unpacked}/usr/share/applications/typeless.desktop \
        $out/share/applications/typeless.desktop
      sed -i 's|^Exec=.*|Exec=typeless %U|' $out/share/applications/typeless.desktop
    '';
  };
in
{
  config = lib.mkIf config.mymodule.apps.typeless.enable {
    environment.systemPackages = [ typeless ];
  };
}
