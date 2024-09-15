{
  config,
  pkgs,
  pkgsFromNiqs,
  # overlays,
  inputs,
  personalizeInput,
  ...
}:
{
  home.packages = with pkgs; [
    pkgsFromNiqs.bibata-hyprcursor
  ];
}
