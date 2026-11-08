{ lib, ... }:
{
  options.mymodule.apps.cloudflare-warp = {
    enable = lib.mkEnableOption "Cloudflare One Client (WARP)";
  };
}
