{ pkgs }:
let
  terminal = "alacritty";
  browser = "zen";
  fileManager = "nautilus";
  menu = "asztal -t launcher";
  mainMod = "Alt";
in
{
  "$terminal" = terminal;
  "$browser" = browser;
  "$fileManager" = fileManager;
  "$menu" = menu;

  monitor = [
    "DP-3,preferred,0x0,auto"
    "HDMI-A-1, 3840x2160@59.94,auto,auto"
  ];

  workspace = [
    "1, monitor:DP-3, default:true"
    "2, monitor:HDMI-A-1, default:true"
  ];

  input = {
    kb_layout = "us";
    repeat_delay = 250;
    repeat_rate = 35;

    touchpad = {
      natural_scroll = true;
      clickfinger_behavior = true;
      scroll_factor = 0.5;
    };

    special_fallthrough = true;
    follow_mouse = "1";
    mouse_refocus = false;
  };

  device = {
    name = "apple-inc.-magic-trackpad";
    sensitivity = 0.4;
  };

  general = {
    gaps_in = 5;
    gaps_out = 20;
    border_size = 2;

    resize_on_border = true;

    layout = "dwindle";
    allow_tearing = false;
  };

  dwindle =
    {
    };

  decoration = {
    rounding = 10;

    blur = {
      enabled = true;
      size = 3;
      passes = 1;
    };

    drop_shadow = "yes";
    shadow_range = 4;
    shadow_render_power = 3;
  };

  animations = {
    enabled = "yes";
    bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

    animation = [
      "windows, 1, 7, myBezier"
      "windowsOut, 1, 7, default, popin 80%"
      "border, 1, 10, default"
      "borderangle, 1, 8, default"
      "fade, 1, 7, default"
      "workspaces, 1, 6, default"
    ];
  };

  # Hyprland Plugins
  plugin = {
    hyprfocus = {
      enabled = "yes";
      animate_floating = "yes";
      animate_workspacechange = "yes";
      focus_animation = "shrink";
      # Beziers for focus animations
      bezier = [
        "bezIn, 0.5,0.0,1.0,0.5"
        "bezOut, 0.0,0.5,0.5,1.0"
        "overshot, 0.05, 0.9, 0.1, 1.05"
        "smoothOut, 0.36, 0, 0.66, -0.56"
        "smoothIn, 0.25, 1, 0.5, 1"
        "realsmooth, 0.28,0.29,.69,1.08"
      ];

      # Flash settings
      # flash {
      #     flash_opacity = 0.95
      #     in_bezier = realsmooth
      #     in_speed = 0.5
      #     out_bezier = realsmooth
      #     out_speed = 3
      # }

      # Shrink settings
      shrink = {
        shrink_percentage = 0.95;
        in_bezier = "realsmooth";
        in_speed = 1;
        out_bezier = "realsmooth";
        out_speed = 2;
      };
    };
  };

  # master {
  #     # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
  #     new_is_master = true
  # }

  gestures = {
    workspace_swipe = true;
    workspace_swipe_distance = 700;
    workspace_swipe_fingers = 4;
    workspace_swipe_cancel_ratio = 0.2;
    workspace_swipe_min_speed_to_force = 5;
    workspace_swipe_direction_lock = true;
    workspace_swipe_direction_lock_threshold = 10;
    workspace_swipe_create_new = true;
  };

  misc = {
    force_default_wallpaper = -1;
  };

  # Example windowrule v1
  # windowrule = float, ^(kitty)$
  # Example windowrule v2
  # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
  # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

  windowrule = [
    "float,^(Floaterm)$"
    "size 25% 30%,^(Floaterm)$"
    "move 60% 60%,^(Floaterm)$"
  ];

  windowrulev2 = [
    "float,class:^(firefox),title:^(ピクチャーインピクチャー)"
    "float,class:^(zen-alpha),title:^(ピクチャーインピクチャー)"
    "pin,class:^(firefox),title:^(ピクチャーインピクチャー)"
    "pin,class:^(zen-alpha),title:^(ピクチャーインピクチャー)"
    "suppressevent maximize, class:.*"
  ];

  # See https://wiki.hyprland.org/Configuring/Keywords/ for more
  "$mainMod" = mainMod;

  bind = [
    # execs
    "$mainMod, Return, exec, $terminal"
    "$mainMod, t, exec, $terminal"
    "$mainMod, q, killactive,"
    "$mainMod, e, exec, $fileManager"
    "$mainMod, f, togglefloating,"
    "$mainMod, r, exec, $menu"
    "$mainMod, Space, exec, $menu"
    "$mainMod, w, exec, $browser"
    "$mainMod SHIFT, R,  exec, asztal -q; asztal" # reload ags
    "Super SHIFT, l, exec, hyprlock"
    # Screenshot
    ",XF86Launch4,   exec, asztal -r 'recorder.start()'"
    ",Print,         exec, asztal -r 'recorder.screenshot()'"
    "SHIFT,Print,    exec, asztal -r 'recorder.screenshot(true)'"

    # Move focus
    "$mainMod, h, movefocus, l"
    "$mainMod, l, movefocus, r"
    "$mainMod, k, movefocus, u"
    "$mainMod, j, movefocus, d"

    # Move active window
    "$mainMod SHIFT, h, movewindow, l"
    "$mainMod SHIFT, l, movewindow, r"
    "$mainMod, SHIFT k, movewindow, u"
    "$mainMod, SHIFT j, movewindow, d"

    # Switch workspaces
    "$mainMod, 1, workspace, 1"
    "$mainMod, 2, workspace, 2"
    "$mainMod, 3, workspace, 3"
    "$mainMod, 4, workspace, 4"
    "$mainMod, 5, workspace, 5"
    "$mainMod, 6, workspace, 6"
    "$mainMod, 7, workspace, 7"
    "$mainMod, 8, workspace, 8"
    "$mainMod, 9, workspace, 9"
    "$mainMod, 0, workspace, 10"

    # Move active window workspace
    "$mainMod SHIFT, 1, focusworkspaceoncurrentmonitor, 1"
    "$mainMod SHIFT, 2, focusworkspaceoncurrentmonitor, 2"
    "$mainMod SHIFT, 3, focusworkspaceoncurrentmonitor, 3"
    "$mainMod SHIFT, 4, focusworkspaceoncurrentmonitor, 4"
    "$mainMod SHIFT, 5, focusworkspaceoncurrentmonitor, 5"
    "$mainMod SHIFT, 6, focusworkspaceoncurrentmonitor, 6"
    "$mainMod SHIFT, 7, focusworkspaceoncurrentmonitor, 7"
    "$mainMod SHIFT, 8, focusworkspaceoncurrentmonitor, 8"
    "$mainMod SHIFT, 9, focusworkspaceoncurrentmonitor, 9"
    "$mainMod SHIFT, 0, focusworkspaceoncurrentmonitor, 10"

    # Example special workspace (scratchpad)
    "$mainMod, s, togglespecialworkspace, magic"
    "$mainMod SHIFT, s, movetoworkspace, special:magic"

    "$mainMod, p, workspace, +1, focuswindow"
    "$mainMod, n, workspace, -1, focuswindow"

    "$mainMod SHIFT, p, movetoworkspace, +1"
    "$mainMod SHIFT, n, movetoworkspace, -1"

    # Change window size
    "$mainMod ctrl, l, resizeactive, 100 100"
    "$mainMod ctrl, h, resizeactive, -100 100"
  ];

  bindm = [
    # Move/resize windows with mainMod + LMB/RMB and dragging
    "$mainMod, mouse:272, movewindow"
    "$mainMod, mouse:273, resizewindow"
  ];

  exec-once = [
    "asztal"
    "conky"
    "playerctld daemon"
    "hyprpaper"
    "fcitx5"
    "discord --start-minimized --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime"
  ];
}
