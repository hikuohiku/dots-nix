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
    (pkgsFromNiqs.bibata-hyprcursor.override
    {
      baseColor = "#FF8300";
      outlineColor = "#FFFFFF";
      watchBackgroundColor = "#001524";
    })
  ];
}
