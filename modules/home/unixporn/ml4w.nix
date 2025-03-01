{
  config,
  pkgs,
  pkgsFromNiqs,
  # overlays,
  inputs,
  userInfo,
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
    fastfetch = {
      enable = true;
      settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
        logo.padding.top = 2;
        display.separator = " ➜  ";
        modules = [
          "break"
          "break"
          "break"
          {
            type = "os";
            key = "OS   ";
            keyColor = "31";
          }
          {
            type = "kernel";
            "key" = " ├  ";
            "keyColor" = "31";
          }
          {
            "type" = "packages";
            "format" = "{} (pacman)";
            "key" = " ├ 󰏖 ";
            "keyColor" = "31";
          }
          {
            "type" = "shell";
            "key" = " └  ";
            "keyColor" = "31";
          }
          "break"
          {
            "type" = "wm";
            "key" = "WM   ";
            "keyColor" = "32";
          }
          {
            "type" = "wmtheme";
            "key" = " ├ 󰉼 ";
            "keyColor" = "32";
          }
          {
            "type" = "icons";
            "key" = " ├ 󰀻 ";
            "keyColor" = "32";
          }
          {
            "type" = "cursor";
            "key" = " ├  ";
            "keyColor" = "32";
          }
          {
            "type" = "terminal";
            "key" = " ├  ";
            "keyColor" = "32";
          }
          {
            "type" = "terminalfont";
            "key" = " └  ";
            "keyColor" = "32";
          }
          "break"
          {
            "type" = "host";
            "format" = "{5} {1} Type {2}";
            "key" = "PC   ";
            "keyColor" = "33";
          }
          {
            "type" = "cpu";
            "format" = "{1} ({3}) @ {7} GHz";
            "key" = " ├  ";
            "keyColor" = "33";
          }
          {
            "type" = "gpu";
            "format" = "{1} {2} @ {12} GHz";
            "key" = " ├ 󰢮 ";
            "keyColor" = "33";
          }
          {
            "type" = "memory";
            "key" = " ├  ";
            "keyColor" = "33";
          }
          {
            "type" = "swap";
            "key" = " ├ 󰓡 ";
            "keyColor" = "33";
          }
          {
            "type" = "disk";
            "key" = " ├ 󰋊 ";
            "keyColor" = "33";
          }
          {
            "type" = "monitor";
            "key" = " └  ";
            "keyColor" = "33";
          }
          "break"
          "break"

        ];
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

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
      package = pkgs.gnome.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    font = {
      name = "Cantarell";
      package = pkgs.cantarell-fonts;
      size = 11;
    };
    gtk2.extraConfig = ''
      gtk-toolbar-style=GTK_TOOLBAR_ICONS
      gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
      gtk-button-images=0
      gtk-menu-images=0
      gtk-enable-event-sounds=1
      gtk-enable-input-feedback-sounds=0
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="rgb"
    '';
    gtk3.extraConfig = {
      gtk-toolbar-style = "GTK_TOOLBAR_ICONS";
      gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk-button-images = 0;
      gtk-menu-images = 0;
      gtk-enable-event-sounds = 1;
      gtk-enable-input-feedback-sounds = 0;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
}
