{ lib, ... }:
{
  options.mymodule.apps.fortivpn = {
    enable = lib.mkEnableOption "FortiVPN (openfortivpn + xbar + proxy)";
  };
}
