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
  ];

  # niri-flake の niri-unstable は古い libglvnd にリンクされ、NVIDIA 595.104 で EGL_EXT_device_query が
  # 見えず起動できない。キャッシュがありシステムと libglvnd が揃う nixpkgs 版を使う。
  programs.niri.package = pkgs.niri;
  # 既定は defaultFontPath を埋め込む override で cache に無くソースビルドになるため、素の版を使う。
  programs.xwayland.package = pkgs.xwayland;

  catppuccin = {
    enable = true;
    autoEnable = false;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bak";
  home-manager.users.hikuo = {
    imports = [
      ./home.nix
      inputs.my.homeManagerModules.default
      inputs.vicinae.homeManagerModules.default
      ./apps.nix
      inputs.catppuccin.homeModules.catppuccin
      inputs.dms.homeModules.dank-material-shell
      inputs.dms.homeModules.niri
      ./niri.nix
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
