{ inputs, inputs', ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.hikuo = {
    imports = with inputs.my.homeManagerModules; [
      ./home.nix
      # my  # Deprecated: no longer needed
      core
      fonts
      terminal
      # zellij  # Migrated to modules-2
      # git  # Migrated to modules-2
      editor
      browser
      cli-tools
      gui-tools
      # fileServer  # Migrated to modules-2/syncthing
      # yabai
      # skhd
      # fortivpn  # Migrated to modules-2
    ] ++ [
      ../../../../modules-2/home.nix
    ];
    mymodule.apps.alacritty.enable = true;
    mymodule.apps.zen.enable = true;
    mymodule.apps.neovim.enable = true;
    mymodule.apps.vscode.enable = true;
    mymodule.apps.fortivpn.enable = true;
    mymodule.apps.git.enable = true;
    mymodule.apps.lazygit.enable = true;
    mymodule.apps.zellij.enable = true;
    mymodule.apps.syncthing.enable = true;
    mymodule.apps.bat.enable = true;
    mymodule.apps.eza.enable = true;
    mymodule.apps.fzf.enable = true;
    # mymodule.apps.yabai.enable = true;
    # mymodule.apps.skhd.enable = true;
  };

  home-manager.extraSpecialArgs = {
    inherit inputs inputs';
    mylib = inputs.my.lib;
    userInfo = {
      username = "hikuo";
      wallpaperPath = "/Users/hikuo/Pictures/wallpaper.jpg";
    };
  };
}
