{
  inputs,
  inputs',
  pkgs,
  ...
}:
{
  imports = [
    ./host.nix
    ./apps.nix
    ./vm.nix
    ./face-auth.nix
    ./hazkey.nix
  ];

  # niri の感度設定はデバイス種別単位のため、Nape Pro を trackball 扱いにして Logitech マウスと設定を分ける。
  services.udev.extraRules = ''
    SUBSYSTEM=="input", ATTRS{name}=="Keychron Nape Pro Mouse", ENV{ID_INPUT_TRACKBALL}="1"
  '';

  # niri-flake の niri-unstable は古い libglvnd にリンクされ、NVIDIA 595.104 で EGL_EXT_device_query が
  # 見えず起動できない。キャッシュがありシステムと libglvnd が揃う nixpkgs 版を使う。
  programs.niri.package = pkgs.niri;
  # nixpkgs の derivation の src だけを main に差し替える。overlay 化により home-manager 側の niri msg も同じ版に揃える。
  nixpkgs.overlays = [
    (final: prev: {
      niri = prev.niri.overrideAttrs (old: {
        version = "unstable-${inputs.niri-src.shortRev}";
        src = inputs.niri-src;
        cargoDeps = final.rustPlatform.importCargoLock {
          lockFile = "${inputs.niri-src}/Cargo.lock";
          allowBuiltinFetchGit = true;
        };
        env = old.env // {
          NIRI_BUILD_COMMIT = inputs.niri-src.shortRev;
        };
        # ビルド時間を短縮する。versionCheckHook は version 属性と niri --version の出力（Cargo.toml 由来）の不一致で失敗するため無効化する。
        doCheck = false;
        doInstallCheck = false;
      });
    })
  ];
  # 既定は defaultFontPath を埋め込む override で cache に無くソースビルドになるため、素の版を使う。
  programs.xwayland.package = pkgs.xwayland;
  # polkit の認証ダイアログは DMS が出す。niri-flake の KDE エージェントが先に登録すると DMS 側が使われない。
  systemd.user.services.niri-flake-polkit.enable = false;

  catppuccin = {
    enable = true;
    autoEnable = false;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bak";
  home-manager.users.hikuo = {
    catppuccin.autoEnable = false;
    imports = [
      ./home.nix
      inputs.my.homeManagerModules.default
      inputs.vicinae.homeManagerModules.default
      ./apps.nix
      inputs.catppuccin.homeModules.catppuccin
      inputs.dms.homeModules.dank-material-shell
      inputs.dms.homeModules.niri
      ./niri.nix
      ./computer-use.nix
    ];
  };

  home-manager.extraSpecialArgs = {
    inherit inputs inputs';
    userInfo = {
      username = "hikuo";
      wallpaperPath = "/home/hikuo/Pictures/wallpaper.jpg";
      git = {
        username = "hikuohiku";
        email = "hikuohiku@gmail.com";
      };
    };
  };
}
