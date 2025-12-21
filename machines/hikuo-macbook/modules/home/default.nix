{ inputs, inputs', ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.hikuo = {
    imports = with inputs.my.homeManagerModules; [
      ./home.nix
      my
      core
      fonts
      terminal
      zellij
      git
      editor
      browser
      cli-tools
      gui-tools
      fileServer
      yabai
      skhd
      fortivpn
    ];
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
