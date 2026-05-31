{ inputs', ... }:
{
  programs.niri.settings = {
    input = {
      keyboard = {
        numlock = true;
        repeat-delay = 250;
        repeat-rate = 50;
      };
      touchpad = {
        tap = true;
        natural-scroll = true;
      };
      mouse.natural-scroll = true;
    };

    outputs."Dell Inc. DELL S2722QC 7VK4MD3" = {
      mode = {
        width = 3840;
        height = 2160;
        refresh = 60.0;
      };
      scale = 1.5;
      position = {
        x = 0;
        y = 0;
      };
      focus-at-startup = true;
    };

    outputs."Dell Inc. DELL S2722DC 7VYRGD3" = {
      mode = {
        width = 2560;
        height = 1440;
        refresh = 59.951;
      };
      scale = 1.0;
      transform.rotation = 270;
      position = {
        x = 2560;
        y = -560;
      };
    };

    layout = {
      gaps = 16;
      center-focused-column = "never";
      preset-column-widths = [
        { proportion = 1.0 / 3.0; }
        { proportion = 1.0 / 2.0; }
        { proportion = 2.0 / 3.0; }
      ];
      default-column-width = {
        proportion = 0.5;
      };
      focus-ring = {
        width = 4;
        active.color = "#7fc8ff";
        inactive.color = "#505050";
      };
      border.enable = false;
    };

    prefer-no-csd = true;
    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    spawn-at-startup = [
      { argv = [ "dms" "run" ]; }
      { argv = [ "xwayland-satellite" ]; }
    ];

    window-rules = [
      {
        matches = [{ app-id = "^org\\.wezfurlong\\.wezterm$"; }];
        default-column-width = { };
      }
      {
        matches = [{ app-id = "^Alacritty$"; }];
        draw-border-with-background = false;
      }
      {
        matches = [{ app-id = "firefox$"; title = "^Picture-in-Picture$"; }];
        open-floating = true;
      }
    ];

    binds = {
      "Mod+Shift+Slash".action.show-hotkey-overlay = [];

      "Mod+A" = {
        hotkey-overlay.title = "Open a Terminal";
        action.spawn = [ "alacritty" ];
      };
      "Mod+Space" = {
        hotkey-overlay.title = "Open Launcher";
        action.spawn = [ "vicinae" "toggle" ];
      };
      "Super+Alt+L" = {
        hotkey-overlay.title = "Lock the Screen";
        action.spawn = [ "swaylock" ];
      };

      "XF86AudioRaiseVolume" = { allow-when-locked = true; action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ]; };
      "XF86AudioLowerVolume" = { allow-when-locked = true; action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ]; };
      "XF86AudioMute" = { allow-when-locked = true; action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ]; };
      "XF86AudioMicMute" = { allow-when-locked = true; action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ]; };

      "Mod+O" = { repeat = false; action.toggle-overview = []; };
      "Mod+Q".action.close-window = [];

      # Focus
      "Mod+Left".action.focus-column-left = [];
      "Mod+Down".action.focus-window-down = [];
      "Mod+Up".action.focus-window-up = [];
      "Mod+Right".action.focus-column-right = [];
      "Mod+H".action.focus-column-left = [];
      "Mod+J".action.focus-workspace-down = [];
      "Mod+K".action.focus-workspace-up = [];
      "Mod+L".action.focus-column-right = [];

      # Move
      "Mod+Ctrl+Left".action.move-column-left = [];
      "Mod+Ctrl+Down".action.move-window-down = [];
      "Mod+Ctrl+Up".action.move-window-up = [];
      "Mod+Ctrl+Right".action.move-column-right = [];
      "Mod+Ctrl+H".action.move-column-left = [];
      "Mod+Ctrl+J".action.move-column-to-workspace-down = [];
      "Mod+Ctrl+K".action.move-column-to-workspace-up = [];
      "Mod+Ctrl+L".action.move-column-right = [];

      "Mod+Home".action.focus-column-first = [];
      "Mod+End".action.focus-column-last = [];
      "Mod+Ctrl+Home".action.move-column-to-first = [];
      "Mod+Ctrl+End".action.move-column-to-last = [];

      # Monitor focus
      "Mod+Shift+Left".action.focus-monitor-left = [];
      "Mod+Shift+Down".action.focus-monitor-down = [];
      "Mod+Shift+Up".action.focus-monitor-up = [];
      "Mod+Shift+Right".action.focus-monitor-right = [];
      "Mod+Shift+H".action.focus-monitor-left = [];
      "Mod+Shift+J".action.focus-monitor-down = [];
      "Mod+Shift+K".action.focus-monitor-up = [];
      "Mod+Shift+L".action.focus-monitor-right = [];

      # Monitor move
      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [];
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [];
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [];
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];
      "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [];
      "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [];
      "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [];
      "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [];

      # Workspace
      "Mod+Page_Down".action.focus-workspace-down = [];
      "Mod+Page_Up".action.focus-workspace-up = [];
      "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [];
      "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [];
      "Mod+Shift+Page_Down".action.move-workspace-down = [];
      "Mod+Shift+Page_Up".action.move-workspace-up = [];

      # Mouse wheel
      "Mod+WheelScrollDown" = { cooldown-ms = 150; action.focus-workspace-down = []; };
      "Mod+WheelScrollUp" = { cooldown-ms = 150; action.focus-workspace-up = []; };
      "Mod+Ctrl+WheelScrollDown" = { cooldown-ms = 150; action.move-column-to-workspace-down = []; };
      "Mod+Ctrl+WheelScrollUp" = { cooldown-ms = 150; action.move-column-to-workspace-up = []; };
      "Mod+WheelScrollRight".action.focus-column-right = [];
      "Mod+WheelScrollLeft".action.focus-column-left = [];
      "Mod+Ctrl+WheelScrollRight".action.move-column-right = [];
      "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [];
      "Mod+Shift+WheelScrollDown".action.focus-column-right = [];
      "Mod+Shift+WheelScrollUp".action.focus-column-left = [];
      "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [];
      "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [];

      # Workspace by index
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+Ctrl+1".action.move-column-to-workspace = 1;
      "Mod+Ctrl+2".action.move-column-to-workspace = 2;
      "Mod+Ctrl+3".action.move-column-to-workspace = 3;
      "Mod+Ctrl+4".action.move-column-to-workspace = 4;
      "Mod+Ctrl+5".action.move-column-to-workspace = 5;
      "Mod+Ctrl+6".action.move-column-to-workspace = 6;
      "Mod+Ctrl+7".action.move-column-to-workspace = 7;
      "Mod+Ctrl+8".action.move-column-to-workspace = 8;
      "Mod+Ctrl+9".action.move-column-to-workspace = 9;

      # Column operations
      "Mod+BracketLeft".action.consume-or-expel-window-left = [];
      "Mod+BracketRight".action.consume-or-expel-window-right = [];
      "Mod+Comma".action.consume-window-into-column = [];
      "Mod+Period".action.expel-window-from-column = [];

      # Resize
      "Mod+R".action.switch-preset-column-width = [];
      "Mod+Shift+R".action.switch-preset-window-height = [];
      "Mod+Ctrl+R".action.reset-window-height = [];
      "Mod+F".action.maximize-column = [];
      "Mod+Shift+F".action.fullscreen-window = [];
      "Mod+Ctrl+F".action.expand-column-to-available-width = [];
      "Mod+C".action.center-column = [];
      "Mod+Ctrl+C".action.center-visible-columns = [];
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      # Floating / tabbed
      "Mod+V".action.toggle-window-floating = [];
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [];
      "Mod+W".action.toggle-column-tabbed-display = [];

      # Screenshot
      "Print".action.screenshot = [];
      "Ctrl+Print".action.screenshot-screen = [];
      "Alt+Print".action.screenshot-window = [];

      # System
      "Mod+Escape" = { allow-inhibiting = false; action.toggle-keyboard-shortcuts-inhibit = []; };
      "Mod+Shift+E".action.quit = [];
      "Ctrl+Alt+Delete".action.quit = [];
      "Mod+Shift+P".action.power-off-monitors = [];
    };
  };

  # niri-flake doesn't support per-output layout overrides yet
  xdg.configFile."niri/output-overrides.kdl".text = ''
    output "Dell Inc. DELL S2722DC 7VYRGD3" {
        layout {
            default-column-width { proportion 1.0; }
        }
    }
  '';

  programs.dank-material-shell.niri = {
    enableSpawn = true;
    includes = {
      enable = true;
      filesToInclude = [
        "alttab"
        "colors"
        "cursor"
        "layout"
        "windowrules"
        "wpblur"
        "../output-overrides"
      ];
    };
  };

  programs.niri.package = inputs'.niri-flake.packages.niri-unstable;
}
