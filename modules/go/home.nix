{
  config,
  lib,
  pkgs,
  ...
}:
let
  goPath = "${config.home.homeDirectory}/go";
in
{
  config = lib.mkIf config.mymodule.apps.go.enable {
    home.packages = with pkgs; [
      go
      gopls
    ];

    # go install の配置先
    home.sessionPath = [ "${goPath}/bin" ];
  };
}
