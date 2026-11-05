{
  config,
  lib,
  options,
  ...
}:
{
  config = lib.optionalAttrs (lib.hasAttrByPath [ "programs" "dank-material-shell" ] options) (
    lib.mkIf config.mymodule.apps.dms.enable {
      programs.dank-material-shell = {
        enable = true;
        # systemd で起動する。DMS の再起動（電源メニュー等）は systemd 経由でないと立ち上がり直さない。
        systemd.enable = true;
      };

      xdg.configFile = {
        # DMS が設定画面から保存するので、書き込める out-of-store symlink にする。
        "dms/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ghq/github.com/hikuohiku/dots-nix/modules/dms/settings.json";
        "dms/plugin_settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ghq/github.com/hikuohiku/dots-nix/modules/dms/plugin_settings.json";
        "dms/themes/sequoia/theme.json".source = ./themes/sequoia/theme.json;
      };
    }
  );
}
