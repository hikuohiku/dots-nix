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

  services = {
    swaync = {
      enable = true;
    };
    #   dunst = {
    #     enable = true;
    #     settings = {
    #       global = {
    #         origin = "top-center";
    #         offset = "(30, 30)";
    #         progress_bar_corner_radius = 0;
    #         transparency = 30;
    #         frame_width = 1;
    #         frame_color = "#ffffff";
    #         font = "Fira Sans Semibold 9";
    #         line_height = 1;
    #         icon_theme = "Papirus-Dark,Adwaita"; 
    #         corner_radius = 10;
    #       };
    #       urgency_low = {
    #         background = "#000000CC";
    #         foreground = "#888888";
    #         timeout = 6;
    #       };
    #       urgency_critical = {
    #         background = "#900000CC";
    #         foreground = "#ffffff";
    #         frame_color = "#ffffff";
    #         timeout = 6;
    #         };
    #     };
    #   };
  };
}
