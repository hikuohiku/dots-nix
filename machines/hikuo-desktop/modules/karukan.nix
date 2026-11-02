{
  inputs,
  pkgs,
  upstream,
  ...
}:
let
  # 上流はソース配布のみで、fcitx5 の ABI にも依存するためここでビルドする。
  karukan = pkgs.rustPlatform.buildRustPackage {
    pname = "fcitx5-karukan";
    version = inputs.karukan.shortRev;
    src = inputs.karukan;
    cargoLock.lockFile = "${inputs.karukan}/Cargo.lock";

    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
      rustPlatform.bindgenHook
    ];
    buildInputs = with pkgs; [
      fcitx5
      kdePackages.extra-cmake-modules
      libxkbcommon
      openssl
    ];

    # Rust ライブラリは CMake が cargo を呼んでビルドする。
    dontUseCmakeConfigure = true;
    buildPhase = ''
      runHook preBuild
      cmake -S karukan-im/fcitx5/fcitx5-addon -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$out \
        -DKARUKAN_NATIVE=OFF
      cmake --build build -j$NIX_BUILD_CORES
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      cmake --install build
      runHook postInstall
    '';
    doCheck = false;
  };

  dict = pkgs.runCommand "karukan-dict-${upstream.karukan-dict.version}" { } ''
    tar -xzf ${upstream.karukan-dict.src}
    install -Dm644 dict.bin $out
  '';
in
{
  i18n.inputMethod.fcitx5.addons = [ karukan ];

  home-manager.users.hikuo.xdg.dataFile."karukan-im/dict.bin".source = dict;
}
