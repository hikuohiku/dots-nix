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

    # Ctrl+Shift+V の詳細表示切り替えが貼り付けと衝突し、設定でも変更できないため無効化する
    # (togatoga/karukan#113)。詳細表示は config.toml の `[display] verbose = true` で使える。
    # 上流のコードが変わっても自動更新を止めないよう、--replace-warn を使う。
    postPatch = ''
      substituteInPlace karukan-im/core/src/core/engine/mod.rs --replace-warn \
        '&& (key.keysym == Keysym::KEY_V || key.keysym == Keysym::KEY_V_UPPER)' \
        '&& false'
    '';

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
  home-manager.users.hikuo.xdg.configFile."karukan-im/config.toml".source = ./karukan-config.toml;
}
