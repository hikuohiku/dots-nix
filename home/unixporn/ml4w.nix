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
    # hypr
    (pkgsFromNiqs.bibata-hyprcursor.override {
      baseColor = "#FF8300";
      outlineColor = "#FFFFFF";
      watchBackgroundColor = "#001524";
    })

  ];

  programs = {
    alacritty = {
      enable = true;
      settings = {
        font = {
          size = 12.0;
          normal.family = "monospace";
        };
        window = {
          opacity = 0.7;
          padding = {
            x = 15;
            y = 15;
          };
        };
      };
    };
  };
}
