{ pkgs, ... }:
{
  home.packages = with pkgs; [
    deno
    pnpm
    nodePackages_latest.prettier
  ];

}
